import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils/_utils.dart';
import 'package:value_bloc/src/utils/disposer.dart';
import 'package:value_bloc/src/utils/emitter.dart';

part '_data_events.dart';
part '_data_states.dart';

typedef ActionHandler<T extends DataBlocAction> = FutureOr<void> Function(
    T event, Emitter<DataBlocEmission> emit);

/// If BLoC is empty or has invalid data you can actuate create or read actions
/// If BLoC has data and data is valid you can actuate create/read/update/delete actions
abstract class DataBloc<TFailure extends Object, TValue,
        TState extends DataBlocState<TValue, TFailure>> extends Bloc<DataBlocEvent, TState>
    with BlocDisposer {
  //
  static Duration readDebounceTime = const Duration();
  final Duration _readDebounceTime;

  static Equals<Object?> defaultEquals = _equals;
  static bool _equals(Object? a, Object? b) => a == b;

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
    if (state.isUpdating && !_previousIsAsync) return;

    // If filter is equal to previous and not force reload block read action
    if (state.hasValidData && _previousFilter == event.filter && !event.canForce) return;

    // Wait last read event
    if (event.isAsync) {
      await Future.delayed(_readDebounceTime);
      if (emit.isDone) return;
      _previousIsAsync = true;
    }

    emit(state.copyWith(isUpdating: true) as TState);
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

    emit(state.copyWith(isUpdating: true) as TState);

    await handler(event, EventEmitter(emit, (event) => mapEmissionToState(event, true)));
  }

  @protected
  TState? mapEmissionToState(DataBlocEmission event, bool isActionEmission) {
    if (event is InvalidateDataBloc) {
      if (!state.hasData) return null;
      return state.copyWith(
        dataStatus: DataBlocStatus.invalid,
      ) as TState;
    }
    if (event is EmitEmittingDataBloc) {
      return state.copyWith(
        isUpdating: event.value,
      ) as TState;
    }
    if (event is EmitFailureDataBloc<TFailure>) {
      return state.copyWith(
        isUpdating: false,
        failure: Param(event.failure),
      ) as TState;
    }
    throw 'Not support $DataBlocEmission<$TFailure, $TValue>\n$event';
  }
}

abstract class DataBlocBase<TEventValue, TFailure extends Object, TValue,
    TState extends DataBlocState<TValue, TFailure>> extends DataBloc<TFailure, TValue, TState> {
  DataBlocBase({
    required Duration? readDebounceTime,
    required TState initialState,
  }) : super(readDebounceTime: readDebounceTime, initialState: initialState);

  // ==================== PUBLIC METHODS ====================

  void delete(TEventValue value) => add(DeleteDataBloc<TEventValue>(value));
}

abstract class ValueBloc<TFailure extends Object, TValue>
    extends DataBlocBase<TValue, TFailure, TValue?, ValueBlocState<TValue?, TFailure>> {
  final Equality<TValue?> _equality;

  ValueBloc({
    Equals<TValue?>? equals,
    bool isUpdating = false,
    TValue? value,
    Duration? readDebounceTime,
  })  : _equality = SimpleEquality(equals ?? DataBloc.defaultEquals),
        super(
            readDebounceTime: readDebounceTime,
            initialState: ValueBlocState(
              equals: equals,
              isUpdating: isUpdating,
              data: value,
            ));

  @protected
  @override
  ValueBlocState<TValue?, TFailure>? mapEmissionToState(
    DataBlocEmission event,
    bool isActionEmission,
  ) {
    Equals;
    Equality;
    if (event is EmitValueDataBloc<TValue?>) {
      return state.copyWith(
        isUpdating: false,
        dataStatus: DataBlocStatus.present,
        data: Param(event.value),
        failure: Param(null),
      );
    }
    if (event is UpdateValueDataBloc<TValue>) {
      if (!state.hasData || state.data != event.value) return null;
      return state.copyWith(
        isUpdating: event.canEmitAgain ? null : false,
        data: Param(event.value),
        failure: event.canEmitAgain ? null : const Param(null),
      );
    }
    if (event is ReplaceValueDataBloc<TValue>) {
      if (!state.hasData || state.data != event.currentValue) return null;
      return state.copyWith(
        isUpdating: event.canEmitAgain ? null : false,
        data: Param(event.nextValue),
        failure: event.canEmitAgain ? null : Param.none,
      );
    }
    return super.mapEmissionToState(event, isActionEmission);
  }
}

abstract class ListBloc<TFailure extends Object, TValue>
    extends DataBlocBase<TValue, TFailure, List<TValue>, ListBlocState<TValue, TFailure>> {
  final Equality<TValue?> _equality;

  ListBloc({
    Equals<TValue?>? equals,
    bool isUpdating = false,
    Iterable<TValue>? values,
    Duration? readDebounceTime,
  })  : _equality = SimpleEquality(equals ?? DataBloc.defaultEquals),
        super(
            readDebounceTime: readDebounceTime,
            initialState: ListBlocState(
              equals: equals,
              isUpdating: isUpdating,
              data: values,
            ));

  // ==================== PUBLIC METHODS ====================

  void deleteAll(Iterable<TValue> value) => add(DeleteDataBloc<Iterable<TValue>>(value));

  @override
  ListBlocState<TValue, TFailure>? mapEmissionToState(
    DataBlocEmission event,
    bool isActionEmission,
  ) {
    if (event is EmitListDataBloc<TValue>) {
      return state.copyWith(
        isUpdating: false,
        failure: Param.none,
        dataStatus: DataBlocStatus.present,
        data: event.values,
      );
    }
    if (event is AddValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWith(
        isUpdating: event.canEmitAgain ? null : false,
        data: state.add([event.value]),
        failure: event.canEmitAgain ? null : const Param(null),
      );
    }
    if (event is UpdateValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWith(
        isUpdating: event.canEmitAgain ? null : false,
        data: state.update([event.value]),
        failure: event.canEmitAgain ? null : const Param(null),
      );
    }
    if (event is ReplaceValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWith(
        isUpdating: event.canEmitAgain ? null : false,
        data: state.replace({event.currentValue: event.nextValue}),
        failure: event.canEmitAgain ? null : const Param(null),
      );
    }
    if (event is RemoveValueDataBloc<TValue>) {
      if (!state.hasData) return null;
      return state.copyWith(
        isUpdating: event.canEmitAgain ? null : false,
        data: state.remove([event.value]),
        failure: event.canEmitAgain ? null : const Param(null),
      );
    }
    return super.mapEmissionToState(event, isActionEmission);
  }
}
