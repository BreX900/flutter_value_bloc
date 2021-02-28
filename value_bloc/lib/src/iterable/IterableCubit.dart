import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/screen/DynamicCubit.dart';
import 'package:value_bloc/src/utils.dart';

part 'IterableState.dart';

abstract class IterableCubit<Value, ExtraData> extends Cubit<IterableCubitState<Value, ExtraData>>
    implements DynamicCubit<IterableCubitState<Value, ExtraData>> {
  IterableCubit(IterableCubitState<Value, ExtraData> state) : super(state);

  void reset();
}

class ListCubit<Value, ExtraData> extends IterableCubit<Value, ExtraData> {
  ListCubit({
    Iterable<Value> values,
    ExtraData initialExtraData,
  }) : super(values == null
            ? IterableCubitUpdating(
                allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
                extraData: initialExtraData,
                oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
              )
            : IterableCubitUpdated(
                oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
                allValues: BuiltMap.build((b) => b
                  ..withBase(() => HashMap())
                  ..addAll(values.toList().asMap())),
                extraData: initialExtraData,
              ));

  // ==================================================
  //                    CUBIT / UI
  // ==================================================

  void update({@required Iterable<Value> values}) {
    emit(state.toUpdated(
      allValues: values.toList().asMap().build(),
    ));
  }

  void remove({@required Iterable<Value> values}) {
    emit(state.toUpdated(
      allValues: state.allValues.rebuild((b) {
        b.removeWhere((_, value) => values.contains(value));
      }),
    ));
  }

  void add({@required Iterable<Value> values}) {
    emit(state.toUpdated(
      allValues: state.allValues.rebuild((b) => b.addAll(values.toList().asMap())),
    ));
  }

  @override
  void reset() {
    emit(state.toUpdating());
  }
}

typedef ListFetcher<Value, Filter> = Stream<IterableFetchEvent<Iterable<Value>>> Function(
  IterableSection section,
  Filter filter,
);

class MultiCubit<Value, Filter, ExtraData> extends IterableCubit<Value, ExtraData>
    with FilteredCubit<Filter, IterableCubitState<Value, ExtraData>> {
  final ListFetcherPlugin _fetcherPlugin;

  final _fetcherSubject = BehaviorSubject<ListFetcher<Value, Filter>>();
  final _selectionsSubject = BehaviorSubject<BuiltSet<IterableSection>>();

  StreamSubscription _sub;

  MultiCubit({
    ListFetcherPlugin fetcherPlugin = const SimpleListFetcherPlugin(),
    ListFetcher<Value, Filter> fetcher,
    Map<int, Value> initialAllValues,
    Filter initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2) filterEquals,
    Duration filterDebounceTime,
    ExtraData initialExtraData,
  })  : _fetcherPlugin = fetcherPlugin,
        super(IterableCubitUpdating(
          allValues: BuiltMap.build((b) {
            b.withBase(() => HashMap());
            if (initialAllValues != null) b.addAll(initialAllValues);
          }),
          extraData: initialExtraData,
          oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        )) {
    final filterStream = Utils.createFilterStream(
      filterStream: onFilterChanges,
      initialFilter: initialFilter,
      canWaitFirstFilter: canWaitFirstFilter,
      filterEquals: filterEquals,
      filterDebounceTime: filterDebounceTime,
    );

    _sub = Rx.combineLatest2<ListFetcher<Value, Filter>, Filter,
        Tuple2<ListFetcher<Value, Filter>, Filter>>(_fetcherSubject, filterStream, (a, b) {
      return Tuple2(a, b);
    }).switchMap((data) {
      final fetcher = data.value1;
      final filter = data.value2;

      emit(state.toUpdating());
      _selectionsSubject.add(BuiltSet.build((b) {
        b.withBase(() => HashSet());
      }));

      return _selectionsSubject.distinct().pairwise().map((vls) {
        // final oldSchemes = vls.first.without(vls.last);
        return vls.last.without(vls.first);
      }).where((newSections) {
        return newSections.isNotEmpty;
      }).flatMap((newSections) {
        return Rx.merge(newSections.map((section) {
          return fetcher(section, filter).map((event) {
            return Tuple2(section, event);
          });
        }));
      });
    }).listen((res) {
      final section = res.value1;
      final event = res.value2;

      int calculateLength(BuiltMap<int, Value> allValues, int pageLength, {int total}) {
        if (total != null) {
          return total;
        } else if (section.length > pageLength) {
          return math.max(section.startAt, allValues.length);
        }
        return state.length;
      }

      if (event is FailedFetchEvent<Iterable<Value>>) {
        emit(state.toUpdateFailed(failure: event.failure));
      } else if (event is EmptyFetchEvent) {
        emit(state.toUpdated(
          length: calculateLength(state.allValues, 0),
        ));
      } else if (event is IterableFetchedEvent<Iterable<Value>>) {
        final page = event.values;

        final allValues = state.allValues.rebuild((b) {
          final pageIterator = page.iterator;
          for (var i = 0; i < section.length && pageIterator.moveNext(); i++) {
            b[section.startAt + i] = pageIterator.current;
          }
        });

        emit(state.toUpdated(
          allValues: allValues,
          length: calculateLength(allValues, page.length, total: event.total),
        ));
      }
    });
    if (fetcher != null) applyFetcher(fetcher: fetcher);
    if (!canWaitFirstFilter || initialFilter == null) applyFilter(filter: initialFilter);
  }

  // ==================================================
  //                        CUBIT
  // ==================================================

  void applyFetcher({@required ListFetcher<Value, Filter> fetcher}) async {
    assert(fetcher != null);
    await Future.delayed(Duration());
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  // ==================================================
  //                         UI
  // ==================================================

  void fetch({@required IterableSection section}) async {
    assert(section != null);
    await Future.delayed(Duration());
    final newSchemes = _fetcherPlugin.update(_selectionsSubject.value, section);
    _selectionsSubject.add(newSchemes);
  }

  @override
  void reset() async {
    await Future.delayed(Duration());
    _fetcherSubject.add(_fetcherSubject.value);
  }

  // ==================================================
  //                        IGNORE
  // ==================================================

  @override
  Future<void> close() {
    _sub.cancel();
    _fetcherSubject.close();
    _selectionsSubject.close();
    return super.close();
  }
}
