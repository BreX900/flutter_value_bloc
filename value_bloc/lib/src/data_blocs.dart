import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils/_utils.dart';
import 'package:value_bloc/src/utils/disposer.dart';
import 'package:value_bloc/src/utils/emitter.dart';
import 'package:value_bloc/value_bloc.dart';

part '_data_events.dart';
part '_data_states.dart';

typedef ActionHandler<T extends DataBlocAction> = FutureOr<void> Function(
    T event, Emitter<DataBlocEmission> emit);

/// If BLoC is empty or has invalid data you can actuate create or read actions
/// If BLoC has data and data is valid you can actuate create/read/update/delete actions
abstract class DataBloc<TFailure, TValue, TState extends DataBlocState<TFailure, TValue>>
    extends Bloc<DataBlocEvent, TState> with BlocDisposer {
  //
  static Duration readDebounceTime = const Duration();
  final Duration _readDebounceTime;

  DataBloc({
    required Duration? readDebounceTime,
    required TState initialState,
  })  : _readDebounceTime = readDebounceTime ?? DataBloc.readDebounceTime,
        super(initialState) {
    on<DataBlocEmission>((event, emit) {
      final state = mapEmissionToState(event, false);
      if (state != null) emit(state);
    }, transformer: sequential());
  }

  // ==================== PUBLIC METHODS ====================

  void read({bool canForce = false, bool isAsync = false}) =>
      add(ReadDataBloc(canForce: canForce, isAsync: isAsync, filter: null));

  // ==================== PROTECTED METHODS ====================

  @protected
  void onCreateAction<A extends CreateDataBloc>(ActionHandler<A> handler) {
    assert('$A' != '$CreateDataBloc', 'Provide action with the type of the value');
    on<A>((event, emit) => _onAction<A>(event, emit, handler), transformer: sequential());
  }

  @protected
  void onReadAction<T>(ActionHandler<ReadDataBloc<T>> handler) {
    on<ReadDataBloc<T>>(
      (event, emit) => _onReadAction<T>(event, emit, handler),
      transformer: assign<ReadDataBloc<T>>((event) {
        return event.isAsync ? ConcurrencyType.restartable : ConcurrencyType.sequential;
      }),
    );
  }

  @protected
  void onUpdateAction<A extends UpdateDataBloc>(ActionHandler<A> handler) {
    assert('$A' != '$UpdateDataBloc', 'Provide action with the type of the value');
    on<A>((event, emit) {
      return _onAction<A>(event, emit, handler, isDataRequired: true);
    }, transformer: concurrent());
  }

  @protected
  void onDeleteAction<A extends DeleteDataBloc>(ActionHandler<A> handler) {
    assert('$A' != '$DeleteDataBloc', 'Provide action with the type of the value');
    on<A>((event, emit) {
      return _onAction<A>(event, emit, handler, isDataRequired: true);
    }, transformer: concurrent());
  }

  @protected
  void onAction<A extends DataBlocAction>(ActionHandler<A> handler, {bool isDataRequired = true}) {
    assert('$A' != '$DataBlocAction');
    on<A>((event, emit) {
      return _onAction<A>(event, emit, handler, isDataRequired: isDataRequired);
    }, transformer: concurrent());
  }

  // ==================== PRIVATE METHODS ====================

  bool _previousIsAsync = false;
  dynamic _previousFilter = Object();
  Future<void> _onReadAction<T>(
    ReadDataBloc<T> event,
    Emitter<TState> emit,
    ActionHandler<ReadDataBloc<T>> handler,
  ) async {
    // Cancel operation if another action is already executing
    // If the previous read action is blocked before completed, continues to perform this action
    if (state.isEmitting && !_previousIsAsync) return;

    // If filter is equal to previous and not force reload block read action
    if (state.hasValidData && _previousFilter == event.filter && !event.canForce) return;

    // Wait last read event
    if (event.isAsync) {
      await Future.delayed(_readDebounceTime);
      if (emit.isDone) return;
      _previousIsAsync = true;
    }

    emit(state.copyWith(isEmitting: true) as TState);
    await handler(event, EventEmitter(emit, (event) => mapEmissionToState(event, true)));

    _previousFilter = event.filter;
    _previousIsAsync = false;
  }

  Future<void> _onAction<T extends DataBlocAction>(
    T event,
    Emitter<TState> emit,
    ActionHandler<T> handler, {
    bool isDataRequired = true,
  }) async {
    // If action required data to work cancel it
    if (isDataRequired) {
      if (!state.hasData || !state.hasValidData) return;
    }

    // If another action is already executing cancel current action
    if (state.isEmitting) return;

    emit(state.copyWith(isEmitting: true) as TState);

    await handler(event, EventEmitter(emit, (event) => mapEmissionToState(event, true)));
  }

  @protected
  TState? mapEmissionToState(DataBlocEmission event, bool isActionEmission) {
    if (event is InvalidateDataBloc) {
      if (!state.hasData) return null;
      return state.copyWith(
        isActionEmission: isActionEmission,
        emission: event,
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

abstract class DataBlocBase<TEventValue, TFailure, TValue,
    TState extends DataBlocState<TFailure, TValue>> extends DataBloc<TFailure, TValue, TState> {
  DataBlocBase({
    required Duration? readDebounceTime,
    required TState initialState,
  }) : super(readDebounceTime: readDebounceTime, initialState: initialState) {}

  // ==================== PUBLIC METHODS ====================

  void delete(TEventValue value) => add(DeleteDataBloc<TEventValue>(value));
}

abstract class ValueBloc<TFailure, TValue>
    extends DataBlocBase<TValue, TFailure, TValue?, SingleDataBlocState<TFailure, TValue?>> {
  ValueBloc({
    Option<TValue> value = const None(),
    Duration? readDebounceTime,
  }) : super(
            readDebounceTime: readDebounceTime,
            initialState: SingleDataBlocState(
              isActionEmission: false,
              emission: null,
              hasValidData: true,
              isEmitting: false,
              failure: None(),
              value: value,
            ));

  @protected
  @override
  SingleDataBlocState<TFailure, TValue?>? mapEmissionToState(
    DataBlocEmission event,
    bool isActionEmission,
  ) {
    if (event is EmitValueDataBloc) {
      return state.copyWith(
        isActionEmission: isActionEmission,
        emission: event,
        hasValidData: true,
        isEmitting: false,
        value: Some(event.value),
        failure: None(),
      );
    }
    if (event is UpdateValueDataBloc<TValue>) {
      if (!state.hasData || state.data != event.value) return null;
      return state.copyWith(
        isActionEmission: isActionEmission,
        emission: event,
        isEmitting: event.canEmitAgain ? null : false,
        value: Some(event.value),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is ReplaceValueDataBloc<TValue>) {
      if (!state.hasData || state.data != event.currentValue) return null;
      return state.copyWith(
        isActionEmission: isActionEmission,
        emission: event,
        isEmitting: event.canEmitAgain ? null : false,
        value: Some(event.nextValue),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    return super.mapEmissionToState(event, isActionEmission);
  }
}

abstract class ListBloc<TFailure, TValue> extends DataBlocBase<TValue, TFailure, BuiltList<TValue>,
    MultiDataBlocState<TFailure, TValue>> {
  ListBloc({
    Option<Iterable<TValue>> values = const None(),
    Duration? readDebounceTime,
  }) : super(
            readDebounceTime: readDebounceTime,
            initialState: MultiDataBlocState(
              isActionEmission: false,
              emission: null,
              isValid: true,
              isEmitting: false,
              failure: None(),
              values: values.map((a) => a.toBuiltList().asMap().build()),
            ));

  // ==================== PUBLIC METHODS ====================

  void deleteAll(BuiltList<TValue> value) => add(DeleteDataBloc<BuiltList<TValue>>(value));

  @override
  MultiDataBlocState<TFailure, TValue>? mapEmissionToState(
    DataBlocEmission event,
    bool isActionEmission,
  ) {
    if (event is EmitListDataBloc<TValue>) {
      return state.copyWithList(
        isActionEmission: isActionEmission,
        emission: event,
        isValid: true,
        isEmitting: false,
        values: Some(event.values.toBuiltList()),
        failure: None(),
      );
    }
    if (event is AddValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isActionEmission: isActionEmission,
        emission: event,
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b.add(event.value))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is UpdateValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isActionEmission: isActionEmission,
        emission: event,
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b
          ..remove(event.value)
          ..add(event.value))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is ReplaceValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      final index = state.data.indexOf(event.currentValue);
      return state.copyWithList(
        isActionEmission: isActionEmission,
        emission: event,
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) {
          if (index == -1) {
            b.add(event.nextValue);
          } else {
            b
              ..removeAt(index)
              ..insert(index, event.nextValue);
          }
        })),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    if (event is RemoveValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWithList(
        isActionEmission: isActionEmission,
        emission: event,
        isEmitting: event.canEmitAgain ? null : false,
        values: Some(state.data.rebuild((b) => b.remove(event.value))),
        failure: event.canEmitAgain ? null : None(),
      );
    }
    return super.mapEmissionToState(event, isActionEmission);
  }
}
