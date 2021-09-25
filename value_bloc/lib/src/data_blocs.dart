import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/utils/disposer.dart';

part '_data_events.dart';
part '_data_states.dart';

abstract class DataBloc<TFailure, TValue, TState extends DataBlocState<TFailure, TValue>>
    extends Bloc<DataBlocEvent, TState> with MapActionToEmission, BlocDisposer {
  //
  static Duration readDebounceTime = const Duration();

  final _readAsyncEventSubject = StreamController<ReadDataBloc>(sync: true);

  DataBloc(TState initialState) : super(initialState) {
    _readAsyncEventSubject.stream
        .cast<ReadDataBloc?>()
        .startWith(null)
        .listenValueChanges<DataBlocEmission>(
          debounceTime: DataBloc.readDebounceTime,
          onStart: (_, curr) async {
            if (curr == null) return;
            await Future.delayed(const Duration());
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
      ..onError(addError)
      ..asDisposable().addTo(this);
  }

  void read({bool canForce = false, bool isAsync = false}) =>
      add(ReadDataBloc(canForce: canForce, isAsync: isAsync));

  ReadDataBloc? _previousReadEvent;

  @override
  Stream<TState> mapEventToState(DataBlocEvent event) async* {
    if (event is DataBlocEmission) {
      yield* mapEmissionToState(event);
    } else if (event is DataBlocAction) {
      if (event is ReadDataBloc) {
        // If event is equal to previous and not force reload block read event
        if (state.hasValidData && _previousReadEvent == event && !event.canForce) return;
        final canAsync = _previousReadEvent != null && event.isAsync;

        // If event is async manage event in async stream
        if (canAsync) {
          _readAsyncEventSubject.add(event);
          return;
        }
        _previousReadEvent = event;
      }
      yield state.copyWith(isEmitting: true) as TState;
      yield* mapActionToEmission(event).asyncExpand(mapEmissionToState);
    }
  }

  Stream<TState> mapEmissionToState(DataBlocEmission event) async* {
    final state = onMapEmissionToState(event);
    if (state == null) return;
    yield state;
  }

  TState? onMapEmissionToState(DataBlocEmission event) {
    if (event is InvalidateDataBloc) {
      if (!state.hasData) return null;
      return state.copyWith(
        hasValidData: false,
      ) as TState;
    }
    if (event is EmitEmittingDataBloc) {
      return state.copyWith(
        isEmitting: event.value,
      ) as TState;
    }
    if (event is EmitFailureDataBloc<TFailure>) {
      return state.copyWith(
        isEmitting: false,
        failure: Some(event.failure),
      ) as TState;
    }
    throw 'Not support $DataBlocEmission<$TFailure, $TValue>\n$event';
  }
}

abstract class ValueBloc<TFailure, TValue>
    extends DataBloc<TFailure, TValue?, SingleDataBlocState<TFailure, TValue?>> {
  ValueBloc({
    Option<TValue> value = const None(),
  }) : super(SingleDataBlocState(
          hasValidData: true,
          isEmitting: false,
          failure: None(),
          value: value,
        ));

  @override
  SingleDataBlocState<TFailure, TValue?>? onMapEmissionToState(DataBlocEmission event) {
    if (event is EmitValueDataBloc) {
      return state.copyWith(
        hasValidData: true,
        isEmitting: false,
        value: Some(event.value),
        failure: None(),
      );
    }
    if (event is UpdateValueDataBloc<TValue>) {
      if (!state.hasData || state.data != event.value) return null;
      return state.copyWith(
        isEmitting: event.canEmitAgain ? null : false,
        value: Some(event.value),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is ReplaceValueDataBloc<TValue>) {
      if (!state.hasData || state.data != event.currentValue) return null;
      return state.copyWith(
        isEmitting: event.canEmitAgain ? null : false,
        value: Some(event.nextValue),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    return super.onMapEmissionToState(event);
  }
}

abstract class ListBloc<TFailure, TValue>
    extends DataBloc<TFailure, BuiltList<TValue>, MultiDataBlocState<TFailure, TValue>> {
  ListBloc({
    Option<Iterable<TValue>> values = const None(),
  }) : super(MultiDataBlocState(
          isValid: true,
          isEmitting: false,
          failure: None(),
          values: values.map((a) => a.toBuiltList().asMap().build()),
        ));

  void emitFailure(TFailure failure) => add(EmitFailureDataBloc(failure));

  void emitValues(BuiltList<TValue> values) => add(EmitListDataBloc(values));

  void addValue(TValue value) => add(AddValueDataBloc(value));

  void replaceValue(TValue oldValue, TValue newValue) =>
      add(ReplaceValueDataBloc(oldValue, newValue));

  void removeValue(TValue value) => add(RemoveValueDataBloc(value));

  @override
  MultiDataBlocState<TFailure, TValue>? onMapEmissionToState(
    DataBlocEmission event,
  ) {
    if (event is EmitListDataBloc<TValue>) {
      return state.copyWithList(
        isValid: true,
        isEmitting: false,
        values: Some(event.values.toBuiltList()),
        failure: None(),
      );
    }
    if (event is AddValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b.add(event.value))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is UpdateValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b
          ..remove(event.value)
          ..add(event.value))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is ReplaceValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b
          ..remove(event.currentValue)
          ..add(event.nextValue))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is RemoveValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b.remove(event.value))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    return super.onMapEmissionToState(event);
  }

  @override
  Future<void> close() {
    _readAsyncEventSubject.close();
    return super.close();
  }
}

mixin MapActionToEmission {
  Stream<DataBlocEmission> mapActionToEmission(DataBlocAction event);
}

// mixin MapSyncEventToEmission<TFailure, TValue> {
//   Stream<DataBlocEmission<TFailure, TValue>> mapSyncEventToEmission(
//     SyncEvent<TValue> event,
//   ) async* {
//     yield onMapSyncEventToEmission(event);
//   }
//
//   DataBlocEmission<TFailure, TValue> onMapSyncEventToEmission(SyncEvent<TValue> event) {
//     if (event is InvalidSyncEvent<TValue>) {
//       return InvalidateDataBloc();
//     }
//     if (event is CreatedSyncEvent<TValue>) {
//       return AddValueDataBloc(event.value, canEmitAgain: true);
//     }
//     if (event is UpdatedSyncEvent<TValue>) {
//       return UpdateValueDataBloc(event.value, canEmitAgain: true);
//     }
//     if (event is ReplacedSyncEvent<TValue>) {
//       return ReplaceValueDataBloc(event.previousValue, event.currentValue, canEmitAgain: true);
//     }
//     if (event is DeletedSyncEvent<TValue>) {
//       return RemoveValueDataBloc(event.value, canEmitAgain: true);
//     }
//     throw 'Not support $event';
//   }
// }
