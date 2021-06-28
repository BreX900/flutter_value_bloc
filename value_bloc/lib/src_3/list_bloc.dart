import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:value_bloc/src_3/list_event.dart';
import 'package:value_bloc/src_3/multi_state.dart';
import 'package:value_bloc/src_3/single_state.dart';

abstract class SingleDataBloc<TEvent, TFailure, TValue,
    TState extends SingleState<TFailure, TValue>> extends Bloc<TEvent, TState> {
  SingleDataBloc(TState initialState) : super(initialState);

  void read();
}

abstract class ValueBloc<TFailure, TValue> extends SingleDataBloc<DataBlocEvent<TFailure, TValue>,
    TFailure, TValue, SingleState<TFailure, TValue>> with MapActionToEmission<TFailure, TValue> {
  ValueBloc({
    Option<TValue> value = const None(),
  }) : super(SingleState(
          isEmitting: false,
          failure: None(),
          value: value,
        ));

  @override
  Stream<SingleState<TFailure, TValue>> mapEventToState(
      DataBlocEvent<TFailure, TValue> event) async* {
    if (event is DataBlocEmission<TFailure, TValue>) {
      yield* mapEmissionToState(event);
    } else if (event is ExternalDataBlocEmission<TFailure, TValue>) {
      if (this != event.bloc && !state.hasValue) return;
      yield* mapEmissionToState(event.event);
    } else if (event is DataBlocAction<TFailure, TValue>) {
      yield* mapActionToEmission(event).asyncExpand(mapEmissionToState);
    }
  }

  Stream<SingleState<TFailure, TValue>> mapEmissionToState(
      DataBlocEmission<TFailure, TValue> event) async* {
    if (event is EmitEmittingDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: true,
      );
    } else if (event is EmitFailureDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: false,
        value: None(),
        failure: Some(event.failure),
      );
    } else if (event is EmitValueDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: false,
        value: Some(event.value),
        failure: None(),
      );
    }
  }
}

abstract class ListBloc<TFailure, TValue> extends SingleDataBloc<
    DataBlocEvent<TFailure, TValue>,
    TFailure,
    BuiltList<TValue>,
    MultiState<TFailure, TValue>> with MapActionToEmission<TFailure, TValue> {
  ListBloc({
    Option<Iterable<TValue>> values = const None(),
  }) : super(MultiState(
          isEmitting: false,
          failure: None(),
          values: values.map((a) => a.toBuiltList().asMap().build()),
        ));

  @override
  Stream<MultiState<TFailure, TValue>> mapEventToState(
      DataBlocEvent<TFailure, TValue> event) async* {
    if (event is DataBlocEmission<TFailure, TValue>) {
      yield* mapEmissionToState(event);
    } else if (event is ExternalDataBlocEmission<TFailure, TValue>) {
      if (this != event.bloc && !state.hasValue) return;
      yield* mapEmissionToState(event.event);
    } else if (event is DataBlocAction<TFailure, TValue>) {
      yield* mapActionToEmission(event).asyncExpand(mapEmissionToState);
    }
  }

  Stream<MultiState<TFailure, TValue>> mapEmissionToState(
      DataBlocEmission<TFailure, TValue> event) async* {
    if (event is EmitEmittingDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: true,
      );
    } else if (event is EmitFailureDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: false,
        values: None(),
        failure: Some(event.failure),
      );
    } else if (event is EmitAddDataBloc<TFailure, TValue> && state.hasValue) {
      yield state.copyWith(
        isEmitting: false,
        values: Some(state.value.rebuild((b) => b.add(event.value)).asMap().build()),
        failure: None(),
      );
    } else if (event is EmitListDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: false,
        values: Some(event.values.toBuiltList().asMap().build()),
        failure: None(),
      );
    } else if (event is EmitReplaceDataBloc<TFailure, TValue> && state.hasValue) {
      yield state.copyWith(
        isEmitting: false,
        values: Some(state.value
            .rebuild((b) => b
              ..remove(event.oldValue)
              ..add(event.newValue))
            .asMap()
            .build()),
        failure: None(),
      );
    } else if (event is EmitRemoveDataBloc<TFailure, TValue> && state.hasValue) {
      yield state.copyWith(
        isEmitting: false,
        values: Some(state.value.rebuild((b) => b.remove(event.value)).asMap().build()),
        failure: None(),
      );
    }
  }
}

mixin MapActionToEmission<TFailure, TValue> {
  Stream<DataBlocEmission<TFailure, TValue>> mapActionToEmission(
      DataBlocAction<TFailure, TValue> event);
}
