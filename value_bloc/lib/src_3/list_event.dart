import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

abstract class DataBlocEvent<TFailure, TValue> extends Equatable {
  const DataBlocEvent();

  DataBlocEmission<TFailure, TValue> toEmitting() => EmitEmittingDataBloc();

  DataBlocEmission<TFailure, TValue> toEmitFailure(TFailure failure) =>
      EmitFailureDataBloc(failure);

  DataBlocEmission<TFailure, TValue> toEmitAdd(TValue value) => EmitAddDataBloc(value);

  DataBlocEmission<TFailure, TValue> toEmitValue(TValue value) => EmitValueDataBloc(value);

  DataBlocEmission<TFailure, TValue> toEmitValues(BuiltList<TValue> values) =>
      EmitListDataBloc(values);

  DataBlocEmission<TFailure, TValue> toEmitReplace(TValue oldValue, TValue newValue) =>
      EmitReplaceDataBloc(oldValue, newValue);

  DataBlocEmission<TFailure, TValue> toEmitRemove(TValue value) => EmitRemoveDataBloc(value);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => onProps;

  List<Object?> get onProps => const [];
}

class ExternalDataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {
  final Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc;
  final DataBlocEmission<TFailure, TValue> event;

  ExternalDataBlocEmission(this.bloc, this.event);

  @override
  List<Object?> get props => [bloc, event, onProps];
}

// ==================== EMISSIONS ====================

abstract class DataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {}

class EmitEmittingDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final bool value;

  EmitEmittingDataBloc([this.value = true]);

  @override
  List<Object?> get props => [value, onProps];
}

class EmitAddDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;

  EmitAddDataBloc(this.value);

  @override
  List<Object?> get props => [value, onProps];
}

class EmitValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;

  EmitValueDataBloc(this.value);

  @override
  List<Object?> get props => [value, onProps];
}

class EmitListDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final Iterable<TValue> values;

  EmitListDataBloc(this.values);

  @override
  List<Object?> get props => [values, onProps];
}

class EmitReplaceDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue oldValue;
  final TValue newValue;

  EmitReplaceDataBloc(this.oldValue, this.newValue);

  @override
  List<Object?> get props => [oldValue, newValue, onProps];
}

class EmitRemoveDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;

  EmitRemoveDataBloc(this.value);

  @override
  List<Object?> get props => [value, onProps];
}

class EmitFailureDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TFailure failure;

  EmitFailureDataBloc(this.failure);

  @override
  List<Object?> get props => [failure, onProps];
}

// ==================== ACTIONS ====================

abstract class DataBlocAction<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {
  const DataBlocAction();
}

abstract class CreateDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {}

class ReadDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {
  final bool canForce;
  final bool isAsync;

  const ReadDataBloc({
    this.canForce = false,
    this.isAsync = false,
  });

  @override
  List<Object?> get props => [canForce, isAsync, onProps];
}

abstract class UpdateDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {}

abstract class DeleteDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {
  final TValue value;

  DeleteDataBloc(this.value);

  @override
  List<Object?> get props => [value, onProps];
}
