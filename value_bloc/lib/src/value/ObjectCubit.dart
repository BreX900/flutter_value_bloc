import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/utils.dart';

part 'ObjectState.dart';

abstract class ObjectCubit<Value, ExtraData> extends Cubit<ObjectState<Value, ExtraData>> {
  ObjectCubit(ObjectState<Value, ExtraData> state) : super(state);

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

typedef ValueFetcher<Value> = Stream<FetchEvent<Value>> Function();

class SingleCubit<Value, ExtraData> extends ObjectCubit<Value, ExtraData> {
  final _fetcherSubject = BehaviorSubject<ValueFetcher<Value>>();
  StreamSubscription _fetcherSub;

  SingleCubit._(
    ObjectState<Value, ExtraData> state, {
    @required ValueFetcher<Value> fetcher,
  }) : super(state) {
    if (fetcher != null) _fetcherSubject.add(fetcher);
    _fetcherSub = _fetcherSubject.doOnCancel(() {
      emit(state.toUpdating());
    }).switchMap((fetcher) {
      return fetcher();
    }).listen((event) {
      if (event is FetchFailedEvent<Value>) {
        emit(state.toUpdateFailed(failure: event.failure));
      } else if (event is FetchedEvent<Value>) {
        emit(state.toUpdated(hasValue: event.hasValue, value: event.value));
      }
    });
  }

  SingleCubit({
    ValueFetcher<Value> fetcher,
    ExtraData initialExtraData,
  }) : this._(ObjectCubitIdle(extraData: initialExtraData), fetcher: fetcher);

  SingleCubit.seed({
    ValueFetcher<Value> fetcher,
    ExtraData initialExtraData,
    @required Value value,
  }) : this._(
          ObjectCubitUpdated(hasValue: true, value: value, extraData: initialExtraData),
          fetcher: fetcher,
        );

  SingleCubit.empty({
    ValueFetcher<Value> fetcher,
    ExtraData initialExtraData,
  }) : this._(
          ObjectCubitUpdated(hasValue: false, value: null, extraData: initialExtraData),
          fetcher: fetcher,
        );

  void applyFetcher({@required ValueFetcher<Value> fetcher}) {
    assert(fetcher != null);
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  @override
  void reset() {
    emit(state.toIdle());
  }

  @override
  Future<void> close() {
    _fetcherSub.cancel();
    _fetcherSubject.close();
    return super.close();
  }
}
