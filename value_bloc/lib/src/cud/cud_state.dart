part of 'cud_cubit.dart';

abstract class CudCubitState<RawValue, PartialValue, Value> extends Equatable {
  const CudCubitState();

  CudCubitState<RawValue, PartialValue, Value> toCreating({
    @required BuiltList<RawValue> values,
  }) {
    return CudCubitCreating(values: values);
  }

  CudCubitState<RawValue, PartialValue, Value> toCreated({
    @required BuiltList<Value> values,
  }) {
    return CudCubitCreated(values: values);
  }

  CudCubitState<RawValue, PartialValue, Value> toUpdating({
    @required BuiltList<PartialValue> values,
  }) {
    return CudCubitUpdating(values: values);
  }

  CudCubitState<RawValue, PartialValue, Value> toUpdated({
    @required BuiltList<Value> values,
  }) {
    return CudCubitUpdated(values: values);
  }

  CudCubitState<RawValue, PartialValue, Value> toDeleting({
    @required BuiltList<Value> values,
  }) {
    return CudCubitDeleting(values: values);
  }

  CudCubitState<RawValue, PartialValue, Value> toDeleted({
    @required BuiltList<Value> values,
  }) {
    return CudCubitDeleted(values: values);
  }
}

class CudCubitIdle<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  @override
  List<Object> get props => [];
}

class CudCubitCreating<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  final BuiltList<RawValue> values;

  const CudCubitCreating({
    @required this.values,
  });

  @override
  List<Object> get props => [values];
}

class CudCubitCreated<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  final BuiltList<Value> values;

  const CudCubitCreated({
    @required this.values,
  });

  @override
  List<Object> get props => [values];
}

class CudCubitUpdating<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  final BuiltList<PartialValue> values;

  const CudCubitUpdating({
    @required this.values,
  });

  @override
  List<Object> get props => [values];
}

class CudCubitUpdated<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  final BuiltList<Value> values;

  const CudCubitUpdated({
    @required this.values,
  });

  @override
  List<Object> get props => [values];
}

class CudCubitDeleting<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  final BuiltList<Value> values;

  const CudCubitDeleting({
    @required this.values,
  });

  @override
  List<Object> get props => [values];
}

class CudCubitDeleted<RawValue, PartialValue, Value>
    extends CudCubitState<RawValue, PartialValue, Value> {
  final BuiltList<Value> values;

  const CudCubitDeleted({
    @required this.values,
  });

  @override
  List<Object> get props => [values];
}
