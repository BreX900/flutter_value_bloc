import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';

abstract class DataBlocEvent<TFailure, TValue> {
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
}

class ExternalDataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {
  final Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc;
  final DataBlocEmission<TFailure, TValue> event;

  ExternalDataBlocEmission(this.bloc, this.event);
}

// ==================== EMISSIONS ====================

abstract class DataBlocEmission<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {}

class EmitEmittingDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {}

class EmitAddDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;

  EmitAddDataBloc(this.value);
}

class EmitValueDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;

  EmitValueDataBloc(this.value);
}

class EmitListDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final Iterable<TValue> values;

  EmitListDataBloc(this.values);
}

class EmitReplaceDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue oldValue;
  final TValue newValue;

  EmitReplaceDataBloc(this.oldValue, this.newValue);
}

class EmitRemoveDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TValue value;

  EmitRemoveDataBloc(this.value);
}

class EmitFailureDataBloc<TFailure, TValue> extends DataBlocEmission<TFailure, TValue> {
  final TFailure failure;

  EmitFailureDataBloc(this.failure);
}

// ==================== ACTIONS ====================

abstract class DataBlocAction<TFailure, TValue> extends DataBlocEvent<TFailure, TValue> {}

abstract class CreateDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {}

abstract class ReadDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {}

abstract class UpdateDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {}

abstract class DeleteDataBloc<TFailure, TValue> extends DataBlocAction<TFailure, TValue> {
  final TValue value;

  DeleteDataBloc(this.value);
}
