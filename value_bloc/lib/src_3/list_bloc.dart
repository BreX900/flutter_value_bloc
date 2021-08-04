import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/screen/disposer.dart';
import 'package:value_bloc/src_3/list_event.dart';
import 'package:value_bloc/src_3/multi_state.dart';
import 'package:value_bloc/src_3/single_state.dart';

abstract class DataBloc {
  static Duration readDebounceTime = const Duration();
}

abstract class SingleDataBloc<TFailure, TValueEvent, TValueState,
        TState extends SingleState<TFailure, TValueState>>
    extends Bloc<DataBlocEvent<TFailure, TValueEvent>, TState> {
  SingleDataBloc(TState initialState) : super(initialState);

  void read({bool canForce = false, bool isAsync = false}) =>
      add(ReadDataBloc<TFailure, TValueEvent>(canForce: canForce, isAsync: isAsync));

  // void emitEmitting() => add(EmitEmittingDataBloc<TFailure, TValue>() as TEvent);
  //
  // void emitFailure(TFailure failure) =>
  //     add(EmitFailureDataBloc<TFailure, TValue>(failure) as TEvent);
}

abstract class ValueBloc<TFailure, TValue>
    extends SingleDataBloc<TFailure, TValue, TValue, SingleState<TFailure, TValue>>
    with MapActionToEmission<TFailure, TValue>, BlocDisposer {
  ValueBloc({
    Option<TValue> value = const None(),
  }) : super(SingleState(
          isEmitting: false,
          failure: None(),
          value: value,
        ));

  @override
  Stream<SingleState<TFailure, TValue>> mapEventToState(
    DataBlocEvent<TFailure, TValue> event,
  ) async* {
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
    DataBlocEmission<TFailure, TValue> event,
  ) async* {
    if (event is EmitEmittingDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: true,
      );
    } else if (event is EmitFailureDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: false,
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

abstract class ListBloc<TFailure, TValue>
    extends SingleDataBloc<TFailure, TValue, BuiltList<TValue>, MultiState<TFailure, TValue>>
    with MapActionToEmission<TFailure, TValue>, BlocDisposer {
  final _onReadAllEvent = StreamController<ReadDataBloc<TFailure, TValue>?>(sync: true);

  ListBloc({
    Option<Iterable<TValue>> values = const None(),
  }) : super(MultiState(
          isEmitting: false,
          failure: None(),
          values: values.map((a) => a.toBuiltList().asMap().build()),
        )) {
    _onReadAllEvent.stream
        .startWith(null)
        .listenValueChanges<DataBlocEmission<TFailure, TValue>>(
          debounceTime: DataBloc.readDebounceTime,
          onStart: (_, curr) {
            if (curr == null) return;
            add(EmitEmittingDataBloc(false));
          },
          onData: (_, curr) async* {
            if (curr == null) return;
            add(EmitEmittingDataBloc());
            yield* mapActionToEmission(curr);
          },
          onFinish: (_, curr, emission) {
            add(emission);
          },
        )
        .addToDisposer(this);
  }

  void emitAdd(TValue value) => add(EmitAddDataBloc(value));

  void emitReplace(TValue oldValue, TValue newValue) =>
      add(EmitReplaceDataBloc(oldValue, newValue));

  void emitRemove(TValue value) => add(EmitRemoveDataBloc(value));

  ReadDataBloc<TFailure, TValue>? _readEvent;

  @override
  Stream<MultiState<TFailure, TValue>> mapEventToState(
    DataBlocEvent<TFailure, TValue> event,
  ) async* {
    if (event is DataBlocEmission<TFailure, TValue>) {
      yield* mapEmissionToState(event);
    } else if (event is ExternalDataBlocEmission<TFailure, TValue>) {
      if (this != event.bloc && !state.hasValue) return;
      yield* mapEmissionToState(event.event);
    } else if (event is DataBlocAction<TFailure, TValue>) {
      if (event is ReadDataBloc<TFailure, TValue>) {
        // If event is equal to previous and not force reload block read event
        if (_readEvent == event && !event.canForce) return;
        _readEvent = event;
        // If event is async manage event in async stream
        if (event.isAsync) {
          _onReadAllEvent.add(event);
          return;
        }
      }
      yield state.copyWith(isEmitting: true);
      yield* mapActionToEmission(event).asyncExpand(mapEmissionToState);
    }
  }

  Stream<MultiState<TFailure, TValue>> mapEmissionToState(
    DataBlocEmission<TFailure, TValue> event,
  ) async* {
    if (event is EmitEmittingDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: event.value,
      );
    } else if (event is EmitFailureDataBloc<TFailure, TValue>) {
      yield state.copyWith(
        isEmitting: false,
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

  @override
  Future<void> close() {
    _onReadAllEvent.close();
    return super.close();
  }
}

mixin MapActionToEmission<TFailure, TValue> {
  Stream<DataBlocEmission<TFailure, TValue>> mapActionToEmission(
      DataBlocAction<TFailure, TValue> event);
}
