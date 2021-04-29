import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
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

  void updateExtraData(ExtraData extraData) async {
    await Future.delayed(const Duration());
    emit(state.copyWith(extraData: Optional.of(extraData)));
  }

  void clear();
}

abstract class CollectionCubit<Value, ExtraData> extends IterableCubit<Value, ExtraData> {
  CollectionCubit(IterableCubitState<Value, ExtraData> state) : super(state);

  // ==================================================
  //                    CUBIT / UI
  // ==================================================

  /// Update the current values with the new [values]
  ///
  /// The status will be set to [IterableCubitUpdated]
  void update({required Iterable<Value> values});

  /// Removes the a [values] to the current values
  ///
  /// The status will be set to [IterableCubitUpdated]
  void remove({required Iterable<Value> values});

  /// Adds the a [values] to the current values
  ///
  /// The status will be set to [IterableCubitUpdated]
  void add({required Iterable<Value> values});

  /// All values are cleared and the initial state is restored
  ///
  /// The status will be set to [IterableCubitUpdating]
  @override
  void clear();
}

class ListCubit<Value, ExtraData> extends CollectionCubit<Value, ExtraData> {
  var _list = <Value>[];

  ListCubit({
    Iterable<Value>? values,
    ExtraData? initialExtraData,
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

  /// See [CollectionCubit.update]
  @override
  void update({required Iterable<Value> values}) async {
    await Future.delayed(const Duration());

    _list = values.toList();
    emit(state.toUpdated(
      allValues: _list.asMap().build(),
    ));
  }

  /// See [CollectionCubit.remove]
  @override
  void remove({required Iterable<Value> values}) async {
    await Future.delayed(const Duration());

    values.forEach(_list.remove);
    emit(state.toUpdated(
      allValues: _list.asMap().build(),
    ));
  }

  /// See [CollectionCubit.add]
  @override
  void add({required Iterable<Value> values}) async {
    await Future.delayed(const Duration());

    _list.addAll(values);
    emit(state.toUpdated(allValues: _list.asMap().build()));
  }

  /// See [CollectionCubit.clear]
  @override
  void clear() async {
    await Future.delayed(const Duration());

    emit(state.toUpdating());
  }
}

class SetCubit<Value, ExtraData> extends CollectionCubit<Value, ExtraData> {
  Set<Value> Function() _base;
  Set<Value> _set;

  factory SetCubit({
    Set<Value> Function()? base,
    Iterable<Value>? values,
    ExtraData? initialExtraData,
  }) {
    base ??= () => <Value>{};
    Set<Value>? set;
    if (values != null) set = base()..addAll(values);
    return SetCubit._(base: base, set: set, initialExtraData: initialExtraData);
  }

  SetCubit._({
    Set<Value> Function()? base,
    Set<Value>? set,
    ExtraData? initialExtraData,
  })  : _base = base ?? (() => <Value>{}),
        _set = set ?? base!(),
        super(set == null
            ? IterableCubitUpdating(
                allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
                extraData: initialExtraData,
                oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
              )
            : IterableCubitUpdated(
                oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
                allValues: BuiltMap.build((b) => b
                  ..withBase(() => HashMap())
                  ..addAll(set.toList().asMap())),
                extraData: initialExtraData,
              ));

  ///  Uses `base` as the collection type for all sets created by this cubit.
  void updateBase({required Set<Value> Function() base}) async {
    await Future.delayed(const Duration());

    _base = base;
    _set = base()..addAll(_set);
    emit(state.copyWith(allValues: Optional.of(_set.toList().asMap().build())));
  }

  /// See [CollectionCubit.update]
  @override
  void update({required Iterable<Value> values}) async {
    await Future.delayed(const Duration());

    _set = _base()..addAll(values);
    emit(state.toUpdated(
      allValues: _set.toList().asMap().build(),
    ));
  }

  /// See [CollectionCubit.remove]
  @override
  void remove({required Iterable<Value> values}) async {
    await Future.delayed(const Duration());

    values.forEach(_set.remove);
    emit(state.toUpdated(
      allValues: _set.toList().asMap().build(),
    ));
  }

  /// See [CollectionCubit.add]
  @override
  void add({required Iterable<Value> values}) async {
    await Future.delayed(const Duration());

    _set.addAll(values);
    emit(state.toUpdated(allValues: _set.toList().asMap().build()));
  }

  /// See [CollectionCubit.clear]
  @override
  void clear() async {
    await Future.delayed(const Duration());

    emit(state.toUpdating());
  }
}

typedef ListFetcher<Value, Filter> = Stream<MultiFetchEvent<Iterable<Value>>> Function(
  IterableSection section,
  Filter filter,
);

/// Allows you to fetch data in a secure and paginated way using the [fetcher] function
class MultiCubit<Value, Filter, ExtraData> extends IterableCubit<Value, ExtraData>
    with FilteredCubit<Filter?, IterableCubitState<Value, ExtraData>> {
  static ListFetcherPlugin defaultFetcherPlugin = const ContinuousListFetcherPlugin();

  final ListFetcherPlugin _fetcherPlugin;

  final _fetcherSubject = BehaviorSubject<ListFetcher<Value, Filter?>>();
  final _selectionsSubject = BehaviorSubject<BuiltSet<IterableSection>>();

  late StreamSubscription _sub;

  MultiCubit({
    ListFetcherPlugin? fetcherPlugin,
    ListFetcher<Value, Filter?>? fetcher,
    Map<int, Value>? initialAllValues,
    Filter? initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter? e1, Filter? e2)? filterEquals,
    Duration? filterDebounceTime,
    ExtraData? initialExtraData,
  })  : _fetcherPlugin = fetcherPlugin ?? defaultFetcherPlugin,
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

    _sub = Rx.combineLatest2<ListFetcher<Value, Filter?>, Filter?,
        Tuple2<ListFetcher<Value, Filter?>, Filter?>>(_fetcherSubject, filterStream, (a, b) {
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
      }).expand((newSections) {
        return newSections;
      }).makeUnique((section) {
        return MapEntry(
            section,
            fetcher(section, filter).map((event) {
              return Tuple2(section, event);
            }));
      });
    }).listen((res) {
      final section = res.value1;
      final event = res.value2;

      int? calculateLength(BuiltMap<int, Value>? allValues, int pageLength, {int? total}) {
        if (total != null) {
          return total;
        } else if (section.length > pageLength) {
          return math.max(section.startAt, allValues!.length);
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
    if (fetcher != null) updateFetcher(fetcher: fetcher);
    if (!canWaitFirstFilter || initialFilter == null) applyFilter(filter: initialFilter);
  }

  // ==================================================
  //                        CUBIT
  // ==================================================

  /// Update method for fetching values/sections
  ///
  /// Once the fetcher has been set up, the cubit will be restored to its initial state.
  /// Listeners will have to request the sections
  /// The status will be set to [IterableCubitUpdating]
  void updateFetcher({required ListFetcher<Value, Filter?> fetcher}) async {
    await Future.delayed(Duration());
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  // ==================================================
  //                         UI
  // ==================================================

  /// Scum the section
  ///
  /// The Fetcher can return these events:
  /// - [FailedFetchEvent] Section fetch failed
  /// - [EmptyFetchEvent] No value was found for the section
  /// - [IterableFetchedEvent] The values for the section were found
  ///
  /// Call the fetcher method and update the status with the new scum [section]
  /// The status will be set to [IterableCubitUpdated] once the data is scrapped but
  /// if you receive an error it will be [IterableCubitUpdateFailed]
  void fetch({required IterableSection section}) async {
    await Future.delayed(Duration());
    final newSchemes = _fetcherPlugin.addTo(_selectionsSubject.value!, section);
    _selectionsSubject.add(newSchemes);
  }

  /// Sets the status to updating and removes all data but does not remove the fetcher
  ///
  /// Listeners will have to request the sections
  /// The status will be set to [IterableCubitUpdating]
  @override
  void clear() async {
    await Future.delayed(Duration());
    _fetcherSubject.add(_fetcherSubject.value!);
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
