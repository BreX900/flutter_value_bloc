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

// Todo: move to pure_extensions package
extension BigExtension<T> on Stream<T> {
  Stream<R> infinityFactory<R>(Stream<R> Function(T event) factory) {
    final subject = PublishSubject<R>();
    final subs = CompositeSubscription();
    subject
      ..onListen = () {
        listen((event) {
          factory(event).listen((event) {
            subject.add(event);
          }).addTo(subs);
        }).addTo(subs);
      }
      ..onCancel = () {
        subs.dispose();
        subject.close();
      };
    return subject;
  }
}

typedef ListFetcher<Value> = Stream<IterableFetchEvent<Iterable<Value>>> Function(
  IterableSection section,
);

class MultiCubit<Value, ExtraData> extends IterableCubit<Value, ExtraData> {
  final ListFetcherPlugin _fetcherPlugin;

  final _fetcherSubject = BehaviorSubject<ListFetcher<Value>>();
  final _selectionsSubject = BehaviorSubject<BuiltSet<IterableSection>>();

  StreamSubscription _sub;

  MultiCubit({
    ListFetcherPlugin fetcherPlugin = const SimpleListFetcherPlugin(),
    ListFetcher<Value> fetcher,
    Map<int, Value> initialAllValues,
    ExtraData initialExtraData,
  })  : _fetcherPlugin = fetcherPlugin,
        super(IterableCubitIdle(
          allValues: BuiltMap.build((b) {
            b.withBase(() => HashMap());
            if (initialAllValues != null) b.addAll(initialAllValues);
          }),
          extraData: initialExtraData,
        )) {
    _sub = _fetcherSubject.switchMap<FetchResult<Value>>((fetcher) {
      emit(state.toIdle());
      _selectionsSubject.add(BuiltSet.build((b) {
        b.withBase(() => HashSet());
      }));

      return _selectionsSubject.distinct().pairwise().map((vls) {
        // final oldSchemes = vls.first.without(vls.last);
        return vls.last.without(vls.first);
      }).where((newSections) {
        return newSections.isNotEmpty;
      }).infinityFactory((newSections) {
        emit(state.toUpdating());

        return Rx.merge<FetchResult<Value>>(newSections.map((section) {
          return fetcher(section).map((event) {
            return FetchResult(section, event);
          });
        }));
      });
    }).listen((res) {
      final section = res.section;
      final event = res.event;

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
  }

  // ==================================================
  //                        CUBIT
  // ==================================================

  void applyFetcher({@required ListFetcher<Value> fetcher}) async {
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

class FetchResult<V> {
  final IterableSection section;
  final IterableFetchEvent<Iterable<V>> event;

  FetchResult(this.section, this.event);
}

class FilterUser {
  final String searchText;
  final bool desc;

  const FilterUser({
    @required this.searchText,
    this.desc,
  });
}
