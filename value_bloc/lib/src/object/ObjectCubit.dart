import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/screen/DynamicCubit.dart';
import 'package:value_bloc/src/utils.dart';

part 'ObjectState.dart';

abstract class ObjectCubit<Value, ExtraData> extends Cubit<ObjectCubitState<Value, ExtraData>>
    implements DynamicCubit<ObjectCubitState<Value, ExtraData>> {
  ObjectCubit(ObjectCubitState<Value, ExtraData> state) : super(state);

  void reset();
}

class ValueCubit<Value, ExtraData> extends ObjectCubit<Value, ExtraData> {
  ValueCubit({
    ExtraData initialExtraData,
  }) : super(ObjectCubitUpdating(hasValue: null, value: null, extraData: initialExtraData));

  ValueCubit.seed({
    @required Value value,
    ExtraData initialExtraData,
  }) : super(ObjectCubitUpdated(hasValue: true, value: value, extraData: initialExtraData));

  ValueCubit.empty({
    ExtraData initialExtraData,
  }) : super(ObjectCubitUpdated(hasValue: false, value: null, extraData: initialExtraData));

  // ==================================================
  //                    CUBIT / UI
  // ==================================================

  void update({@required Value value}) {
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

typedef ValueFetcher<Value, Filter> = Stream<ObjectFetchEvent<Value>> Function(Filter filter);

class SingleCubit<Value, Filter, ExtraData> extends ObjectCubit<Value, ExtraData>
    with FilteredCubit<Filter, ObjectCubitState<Value, ExtraData>> {
  final _fetcherSubject = BehaviorSubject<ValueFetcher<Value, Filter>>();
  final _canFetchSubject = BehaviorSubject<bool>();
  StreamSubscription _sub;

  SingleCubit._(
    ObjectCubitState<Value, ExtraData> state, {
    @required ValueFetcher<Value, Filter> fetcher,
    Filter initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2) filterEquals,
    Duration filterDebounceTime,
  }) : super(state) {
    final filterStream = Utils.createFilterStream(
      filterStream: onFilterChanges,
      initialFilter: initialFilter,
      canWaitFirstFilter: canWaitFirstFilter,
      filterEquals: filterEquals,
      filterDebounceTime: filterDebounceTime,
    );

    _sub = Rx.combineLatest2<ValueFetcher<Value, Filter>, Filter,
        Tuple2<ValueFetcher<Value, Filter>, Filter>>(_fetcherSubject, filterStream, (a, b) {
      return Tuple2(a, b);
    }).switchMap<ObjectFetchEvent<Value>>((data) async* {
      final fetcher = data.value1;
      final filter = data.value2;

      _canFetchSubject.add(false);
      emit(state.toIdle());
      await Future.delayed(Duration());

      yield* _canFetchSubject.asyncExpand((canFetch) async* {
        if (!canFetch) return;

        emit(state.toUpdating());
        await Future.delayed(Duration());

        yield* fetcher(filter);
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

  SingleCubit({
    ValueFetcher<Value, Filter> fetcher,
    Filter initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2) filterEquals,
    Duration filterDebounceTime,
    ExtraData initialExtraData,
  }) : this._(
          ObjectCubitIdle(extraData: initialExtraData),
          fetcher: fetcher,
          initialFilter: initialFilter,
          canWaitFirstFilter: canWaitFirstFilter,
          filterEquals: filterEquals,
          filterDebounceTime: filterDebounceTime,
        );

  SingleCubit.seed({
    ValueFetcher<Value, Filter> fetcher,
    Filter initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2) filterEquals,
    Duration filterDebounceTime,
    ExtraData initialExtraData,
    @required Value initialValue,
  }) : this._(
          ObjectCubitUpdated(hasValue: true, value: initialValue, extraData: initialExtraData),
          fetcher: fetcher,
          initialFilter: initialFilter,
          canWaitFirstFilter: canWaitFirstFilter,
          filterEquals: filterEquals,
          filterDebounceTime: filterDebounceTime,
        );

  SingleCubit.empty({
    ValueFetcher<Value, Filter> fetcher,
    Filter initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2) filterEquals,
    Duration filterDebounceTime,
    ExtraData initialExtraData,
  }) : this._(
          ObjectCubitUpdated(hasValue: false, value: null, extraData: initialExtraData),
          fetcher: fetcher,
          initialFilter: initialFilter,
          canWaitFirstFilter: canWaitFirstFilter,
          filterEquals: filterEquals,
          filterDebounceTime: filterDebounceTime,
        );

  void applyFetcher({@required ValueFetcher<Value, Filter> fetcher}) async {
    assert(fetcher != null);
    await Future.delayed(Duration());

    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  void fetch() async {
    await Future.delayed(Duration());

    _canFetchSubject.add(true);
  }

  @override
  void reset() async {
    await Future.delayed(Duration());

    _fetcherSubject.add(_fetcherSubject.value);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    _fetcherSubject.close();
    return super.close();
  }
}
