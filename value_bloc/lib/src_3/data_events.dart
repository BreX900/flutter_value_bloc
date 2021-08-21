part of 'data_blocs.dart';

abstract class DataBlocEvent<TFailure, TValue> with EquatableMixin {
  const DataBlocEvent();

  DataBlocEmission<TFailure, TValue> toEmitting() => EmitEmittingDataBloc();

  DataBlocEmission<TFailure, TValue> toEmitFailure(TFailure failure) =>
      EmitFailureDataBloc(failure);

  DataBlocEmission<TFailure, TValue> toEmitValue(TValue value) => EmitValueDataBloc(value);

  DataBlocEmission<TFailure, TValue> toEmitList(BuiltList<TValue> values) =>
      EmitListDataBloc(values);

  DataBlocEmission<TFailure, TValue> toAddValue(TValue value) => AddValueDataBloc(value);

  DataBlocEmission<TFailure, TValue> toReplaceValue(TValue oldValue, TValue newValue) =>
      ReplaceValueDataBloc(oldValue, newValue);

  DataBlocEmission<TFailure, TValue> toRemoveValue(TValue value) => RemoveValueDataBloc(value);

  @override
  bool? get stringify => true;
}

class ExternalDataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {
  final Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc;
  final DataBlocEmission<TFailure, TValue> event;

  ExternalDataBlocEmission(this.bloc, this.event);

  @override
  List<Object?> get props => [bloc, event];
}

// ==================== EMISSIONS ====================

abstract class DataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {}

class EmitEmittingDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final bool value;

  EmitEmittingDataBloc([this.value = true]);

  @override
  List<Object?> get props => [value];
}

class EmitFailureDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TFailure failure;

  EmitFailureDataBloc(this.failure);

  @override
  List<Object?> get props => [failure];
}

class EmitValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue? value;

  EmitValueDataBloc(this.value);

  @override
  List<Object?> get props => [value];
}

class EmitListDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final Iterable<TValue> values;

  EmitListDataBloc(this.values);

  @override
  List<Object?> get props => [values];
}

class InvalidateDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  @override
  List<Object?> get props => [];
}

class AddValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;
  final bool canEmitAgain;

  AddValueDataBloc(this.value, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [value];
}

class UpdateValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;
  final bool canEmitAgain;

  UpdateValueDataBloc(this.value, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [value];
}

class ReplaceValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue currentValue;
  final TValue nextValue;
  final bool canEmitAgain;

  ReplaceValueDataBloc(this.currentValue, this.nextValue, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [currentValue, nextValue];
}

class RemoveValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;
  final bool canEmitAgain;

  RemoveValueDataBloc(this.value, {this.canEmitAgain = false});

  @override
  List<Object?> get props => [value];
}

// ==================== ACTIONS ====================

abstract class DataBlocAction<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {
  const DataBlocAction();

  @override
  List<Object?> get props => onProps;

  List<Object?> get onProps => const [];
}

abstract class CreateDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {}

class ReadDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {
  final bool canForce;
  final bool isAsync;

  ReadDataBloc({
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
