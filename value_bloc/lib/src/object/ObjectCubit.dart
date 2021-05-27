import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/screen/DynamicCubit.dart';
import 'package:value_bloc/src/utils.dart';

part 'ObjectState.dart';

abstract class ObjectCubit<Value, ExtraData> extends Cubit<ObjectCubitState<Value, ExtraData>>
    implements DynamicCubit<ObjectCubitState<Value, ExtraData>> {
  ObjectCubit(ObjectCubitState<Value, ExtraData> state) : super(state);

  void updateExtraData(ExtraData extraData) async {
    await Future.delayed(const Duration());
    emit(state.copyWith(extraData: Optional.of(extraData)));
  }

  void reset();
}

/// Allows you to wait for the loading of a value,
/// if it is not successful it notifies the failure otherwise it notifies the new value
class ValueCubit<Value, ExtraData> extends ObjectCubit<Value, ExtraData> {
  /// Create the cubit that is waiting to receive a value,
  /// the initial state is [ObjectCubitUpdating]
  ValueCubit({
    ExtraData? initialExtraData,
  }) : super(ObjectCubitUpdating(
          hasValue: null,
          value: null,
          extraData: initialExtraData,
          oldValue: null,
        ));

  /// Create the cubit with an initial value, the initial state is [ObjectCubitUpdated]
  ValueCubit.seed({
    required Value value,
    ExtraData? initialExtraData,
  }) : super(ObjectCubitUpdated(
          hasValue: true,
          value: value,
          extraData: initialExtraData,
          oldValue: null,
        ));

  /// Create the cubit without a value, the initial state is [ObjectCubitUpdated]
  ValueCubit.empty({
    ExtraData? initialExtraData,
  }) : super(ObjectCubitUpdated(
          hasValue: false,
          value: null,
          extraData: initialExtraData,
          oldValue: null,
        ));

  // ==================================================
  //                    CUBIT / UI
  // ==================================================

  /// Update the current value
  ///
  ///
  void update({required Value value}) {
    emit(state.toUpdated(hasValue: true, value: value));
  }

  void clear() {
    emit(state.toUpdated(hasValue: false, value: null));
  }

  @override
  void reset() {
    emit(state.toUpdating());
  }
}

typedef ValueFetcher<Value, Filter> = Stream<SingleFetchEvent<Value>> Function(Filter? filter);

/// It allows you to wait for the fetch of a value,
/// if it is not successful it notifies the failure,
/// if the value does not exist it notifies the non-existence
/// otherwise it notifies the new value.
class SingleCubit<Value, Filter, ExtraData> extends ObjectCubit<Value, ExtraData>
    with FilteredCubit<Filter?, ObjectCubitState<Value, ExtraData>> {
  final _fetcherSubject = BehaviorSubject<ValueFetcher<Value, Filter>>();
  final _canFetchSubject = BehaviorSubject<bool>();
  late StreamSubscription _sub;

  /// Create the cubit that is waiting to receive a value,
  /// the initial state is [ObjectCubitUpdating]
  SingleCubit({
    ValueFetcher<Value, Filter>? fetcher,
    Filter? initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter? e1, Filter? e2)? filterEquals,
    Duration? filterDebounceTime,
    ExtraData? initialExtraData,
  }) : this._(
          ObjectCubitUpdating(extraData: initialExtraData, oldValue: null),
          fetcher: fetcher,
          initialFilter: initialFilter,
          canWaitFirstFilter: canWaitFirstFilter,
          filterEquals: filterEquals,
          filterDebounceTime: filterDebounceTime,
        );

  /// Create the cubit with an initial value, the initial state is [ObjectCubitUpdated]
  SingleCubit.seed({
    ValueFetcher<Value, Filter>? fetcher,
    Filter? initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter? e1, Filter? e2)? filterEquals,
    Duration? filterDebounceTime,
    ExtraData? initialExtraData,
    required Value initialValue,
  }) : this._(
          ObjectCubitUpdated(
            hasValue: true,
            value: initialValue,
            extraData: initialExtraData,
            oldValue: null,
          ),
          fetcher: fetcher,
          initialFilter: initialFilter,
          canWaitFirstFilter: canWaitFirstFilter,
          filterEquals: filterEquals,
          filterDebounceTime: filterDebounceTime,
        );

  /// Create the cubit without a value, the initial state is [ObjectCubitUpdated]
  SingleCubit.empty({
    ValueFetcher<Value, Filter>? fetcher,
    Filter? initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter? e1, Filter? e2)? filterEquals,
    Duration? filterDebounceTime,
    ExtraData? initialExtraData,
  }) : this._(
          ObjectCubitUpdated(
            hasValue: false,
            value: null,
            extraData: initialExtraData,
            oldValue: null,
          ),
          fetcher: fetcher,
          initialFilter: initialFilter,
          canWaitFirstFilter: canWaitFirstFilter,
          filterEquals: filterEquals,
          filterDebounceTime: filterDebounceTime,
        );

  SingleCubit._(
    ObjectCubitState<Value, ExtraData> superState, {
    required ValueFetcher<Value, Filter>? fetcher,
    Filter? initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter? e1, Filter? e2)? filterEquals,
    Duration? filterDebounceTime,
  }) : super(superState) {
    final filterStream = Utils.createFilterStream(
      filterStream: onFilterChanges,
      initialFilter: initialFilter,
      canWaitFirstFilter: canWaitFirstFilter,
      filterEquals: filterEquals,
      filterDebounceTime: filterDebounceTime,
    );

    _sub = Rx.combineLatest2<ValueFetcher<Value, Filter>, Filter?,
        Tuple2<ValueFetcher<Value, Filter>, Filter?>>(_fetcherSubject, filterStream, (a, b) {
      return Tuple2(a, b);
    }).switchMap<SingleFetchEvent<Value>>((data) async* {
      final fetcher = data.value1;
      final filter = data.value2;

      _canFetchSubject.add(false);

      emit(state.toUpdating());
      await Future.delayed(Duration());
      // Todo: check recall fetcher method with ui
      yield* _canFetchSubject.distinct().asyncExpand((canFetch) {
        if (!canFetch) return Stream.empty();

        return fetcher(filter);
      });
    }).listen((event) {
      if (event is FailedFetchEvent<Value>) {
        emit(state.toUpdateFailed(failure: event.failure));
      } else if (event is EmptyFetchEvent<Value>) {
        emit(state.toUpdated(hasValue: false, value: null));
      } else if (event is ObjectFetchedEvent<Value>) {
        emit(state.toUpdated(hasValue: true, value: event.value));
      }
    });
    // Initializer Streams
    if (fetcher != null) _fetcherSubject.add(fetcher);
    if (!canWaitFirstFilter || initialFilter == null) applyFilter(filter: initialFilter);
  }

  void applyFetcher({required ValueFetcher<Value, Filter> fetcher}) async {
    await Future.delayed(const Duration());

    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  void fetch() async {
    await Future.delayed(const Duration());

    _canFetchSubject.add(true);
  }

  @override
  void reset() async {
    await Future.delayed(const Duration());

    _fetcherSubject.add(_fetcherSubject.value);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    _fetcherSubject.close();
    return super.close();
  }
}
