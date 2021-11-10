part of 'data_blocs.dart';

abstract class DataBlocEvent with EquatableMixin {
  const DataBlocEvent();

  DataBlocEmission toEmitting() => EmitEmittingDataBloc();

  EmitFailureDataBloc<TFailure> toEmitFailure<TFailure extends Object>(TFailure failure) =>
      EmitFailureDataBloc(failure);

  EmitValueDataBloc<TValue> toEmitValue<TValue>(TValue value) => EmitValueDataBloc(value);

  EmitListDataBloc<TValue> toEmitList<TValue>(Iterable<TValue> values) => EmitListDataBloc(values);

  AddValueDataBloc<TValue> toAddValue<TValue>(TValue value) => AddValueDataBloc(value);

  ReplaceValueDataBloc<TValue> toReplaceValue<TValue>(TValue oldValue, TValue newValue) =>
      ReplaceValueDataBloc(oldValue, newValue);

  RemoveValueDataBloc<TValue> toRemoveValue<TValue>(TValue value) => RemoveValueDataBloc(value);

  @override
  bool? get stringify => true;
}

// class ExternalDataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {
//   final Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc;
//   final DataBlocEmission<TFailure, TValue> event;
//
//   ExternalDataBlocEmission(this.bloc, this.event);
//
//   @override
//   List<Object?> get props => [bloc, event];
// }

// ==================== EMISSIONS ====================

abstract class DataBlocEmission extends DataBlocEvent {}

class EmitEmittingDataBloc extends DataBlocEmission {
  final bool value;

  EmitEmittingDataBloc([this.value = true]);

  @override
  List<Object?> get props => [value];
}

class EmitFailureDataBloc<TFailure extends Object> extends DataBlocEmission {
  final TFailure failure;

  EmitFailureDataBloc(this.failure);

  @override
  List<Object?> get props => [failure];
}

class EmitValueDataBloc<TValue> extends DataBlocEmission {
  final TValue? value;

  EmitValueDataBloc(this.value);

  @override
  List<Object?> get props => [value];
}

class EmitListDataBloc<TValue> extends DataBlocEmission {
  final Iterable<TValue> values;

  EmitListDataBloc(this.values);

  @override
  List<Object?> get props => [values];
}

class InvalidateDataBloc extends DataBlocEmission {
  @override
  List<Object?> get props => [];
}

class AddValueDataBloc<TValue> extends DataBlocEmission {
  final TValue value;
  final bool canEmitAgain;

  AddValueDataBloc(this.value, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [value];
}

class UpdateValueDataBloc<TValue> extends DataBlocEmission {
  final TValue value;
  final bool canEmitAgain;

  UpdateValueDataBloc(this.value, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [value];
}

class ReplaceValueDataBloc<TValue> extends DataBlocEmission {
  final TValue currentValue;
  final TValue nextValue;
  final bool canEmitAgain;

  ReplaceValueDataBloc(this.currentValue, this.nextValue, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [currentValue, nextValue];
}

class RemoveValueDataBloc<TValue> extends DataBlocEmission {
  final TValue value;
  final bool canEmitAgain;

  RemoveValueDataBloc(this.value, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [value];
}

// ==================== ACTIONS ====================

abstract class DataBlocAction extends DataBlocEvent {
  const DataBlocAction();

  @override
  List<Object?> get props => onProps;

  List<Object?> get onProps => const [];
}

class CreateDataBloc extends DataBlocAction {
  CreateDataBloc();
}

class ReadDataBloc<TFilter> extends DataBlocAction {
  final bool canForce;
  final bool isAsync;
  final TFilter filter;

  ReadDataBloc({
    this.canForce = false,
    this.isAsync = false,
    required this.filter,
  });

  @override
  List<Object?> get props => [canForce, isAsync, filter, onProps];
}

class UpdateDataBloc<TValue> extends DataBlocAction {
  final TValue value;

  UpdateDataBloc(this.value);

  @override
  List<Object?> get props => [value, onProps];
}

class DeleteDataBloc<TValue> extends DataBlocAction {
  final TValue value;

  DeleteDataBloc(this.value);

  @override
  List<Object?> get props => [value, onProps];
}
