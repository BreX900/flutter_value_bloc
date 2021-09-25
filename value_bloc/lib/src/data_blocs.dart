import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/utils/disposer.dart';
import 'package:value_bloc/src/utils/emitter.dart';

part '_data_events.dart';
part '_data_states.dart';

// extension EmitDataBlocState<TFailure, TValue> on Emitter<DataBlocState<TFailure, TValue>> {
//   void emitting(DataBlocState<TFailure, TValue> state) => this(state.copyWith(isEmitting: true));
//
//   void failure(DataBlocState<TFailure, TValue> state) => this(state);
// }

Stream<DataBlocEvent> dio(Stream<DataBlocEvent> _events, EventMapper<DataBlocEvent> mapper) {
  final events = _events.cast<ReadDataBloc>();

  final asyncController = StreamController<ReadDataBloc?>();
  final syncController = StreamController<DataBlocEvent>();
  final resultController = StreamController<DataBlocEvent>();

  events.listen((event) {
    if (event.isAsync) {
      asyncController.add(event);
    } else {
      asyncController.add(null);
      syncController.add(event);
    }
  });

  asyncController.stream.switchMap<DataBlocEvent>((event) {
    if (event == null) return Stream.empty();
    return mapper(event);
  }).listen(syncController.add);

  syncController.stream.asyncExpand((event) {
    if (event is ReadDataBloc) {
      if (event.isAsync) throw 'Illegal argument ReadDataBloc.isAsync';
      return mapper(event);
    } else {
      return Stream.value(event);
    }
  }).listen(resultController.add);

  return resultController.stream;
}

typedef ActionHandler<T extends DataBlocAction> = FutureOr<void> Function(
    T event, Emitter<DataBlocEmission> emit);

abstract class DataBloc<TFailure, TValue, TState extends DataBlocState<TFailure, TValue>>
    extends Bloc<DataBlocEvent, TState> with BlocDisposer {
  //
  static Duration readDebounceTime = const Duration();

  DataBloc(TState initialState) : super(initialState) {
    on<DataBlocEmission>((event, emit) {
      final state = mapEmissionToState(event);
      if (state != null) emit(state);
    });
    on((event, emit) {
      print('->$event');
    });
  }

  void read({bool canForce = false, bool isAsync = false}) =>
      add(ReadDataBloc(canForce: canForce, isAsync: isAsync));

  void onRead<T extends ReadDataBloc>(ActionHandler<T> handler) {
    on<T>((event, emit) => _onRead<T>(event, emit, handler), transformer: dio);
  }

  void onAction<T extends DataBlocAction>(ActionHandler<T> handler) {
    on<T>((event, emit) => _onAction<T>(event, emit, handler), transformer: sequential());
  }

  ReadDataBloc? _previousReadEvent;
  Future<void> _onRead<T extends ReadDataBloc>(
    T event,
    Emitter<TState> emit,
    ActionHandler<T> handler,
  ) async {
    // If event is equal to previous and not force reload block read event
    if (state.hasValidData && _previousReadEvent == event && !event.canForce) return;

    if (event.isAsync) {
      await Future.delayed(DataBloc.readDebounceTime);
      if (emit.isDone) return;
    }

    emit(state.copyWith(isEmitting: true) as TState);
    await handler(event, EventEmitter(emit, mapEmissionToState));
    _previousReadEvent = event;
  }

  Future<void> _onAction<T extends DataBlocAction>(
    T event,
    Emitter<TState> emit,
    ActionHandler<T> handler,
  ) async {
    if (!state.hasData || !state.hasValidData) return;

    emit(state.copyWith(isEmitting: true) as TState);

    await handler(event, EventEmitter(emit, mapEmissionToState));
  }

  TState? mapEmissionToState(DataBlocEmission event) {
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
  SingleDataBlocState<TFailure, TValue?>? mapEmissionToState(DataBlocEmission event) {
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
    return super.mapEmissionToState(event);
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
  MultiDataBlocState<TFailure, TValue>? mapEmissionToState(DataBlocEmission event) {
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
    return super.mapEmissionToState(event);
  }
}
