import 'dart:async';
import 'dart:collection';

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

typedef ListFetcher<Value> = Stream<IterableFetchEvent<Iterable<Value>>> Function(
  IterableSection section,
);

class MultiCubit<Value, ExtraData> extends IterableCubit<Value, ExtraData> {
  final ListFetcherPlugin _fetcherPlugin;

  final _fetcherSubject = BehaviorSubject<ListFetcher<Value>>();
  final _selectionsSubject = BehaviorSubject<BuiltSet<IterableSection>>.seeded(BuiltSet.build((b) {
    b.withBase(() => HashSet());
  }));

  StreamSubscription _sub;
  final _subs = CompositeMapSubscription<IterableSection>();

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
    if (fetcher != null) _fetcherSubject.add(fetcher);
    _sub = _selectionsSubject.pairwise().listen((vls) {
      final newSchemes = vls.last.without(vls.first);
      final oldSchemes = vls.first.without(vls.last);

      // Remove old subscriptions and values
      oldSchemes.forEach((scheme) async {
        await _subs.remove(scheme);
        emit(state.toUpdated(
          allValues: state.allValues.rebuild((b) {
            for (var i = scheme.startAt; i < scheme.endAt; i++) {
              b.remove(i);
            }
          }),
        ));
      });

      if (newSchemes.isNotEmpty) emit(state.toUpdating());

      // Add new subscriptions for every new scheme and add values
      newSchemes.forEach((scheme) {
        _fetcherSubject.switchMap((fetcher) {
          if (fetcher == null) return Stream.empty();
          return fetcher(scheme);
        }).listen((event) {
          if (event is FailedFetchEvent<Iterable<Value>>) {
            emit(state.toUpdateFailed(failure: event.failure));
          } else if (event is EmptyFetchEvent) {
            emit(state.toUpdated(
              length: state.allValues.length,
            ));
          } else if (event is IterableFetchedEvent<Iterable<Value>>) {
            final page = event.values;

            final allValues = state.allValues.rebuild((b) {
              final pageIterator = page.iterator;
              for (var i = 0; i < scheme.length && pageIterator.moveNext(); i++) {
                b[i + scheme.startAt] = pageIterator.current;
              }
            });
            final length = event.total ??
                state.length ??
                (page.length < scheme.endAt ? allValues.length : null);

            emit(state.toUpdated(
              allValues: allValues,
              length: length,
            ));
          }
        }).addToByKey(_subs, scheme);
      });
    });
  }

  // ==================================================
  //                        CUBIT
  // ==================================================

  void applyFetcher({@required ListFetcher<Value> fetcher}) {
    assert(fetcher != null);
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  // ==================================================
  //                         UI
  // ==================================================

  void fetch({@required IterableSection section}) {
    final newSchemes = _fetcherPlugin.update(_selectionsSubject.value, section);
    _selectionsSubject.add(newSchemes);
  }

  @override
  void reset() async {
    _selectionsSubject.add(_selectionsSubject.value.rebuild((b) => b.clear()));
    emit(state.toIdle());
  }

  // ==================================================
  //                        IGNORE
  // ==================================================

  @override
  Future<void> close() {
    _subs.dispose();
    _sub.cancel();
    _fetcherSubject.close();
    _selectionsSubject.close();
    return super.close();
  }
}
