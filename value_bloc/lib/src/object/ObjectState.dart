part of 'ObjectCubit.dart';

abstract class ObjectCubitState<Value, ExtraData> extends Equatable {
  final bool hasValue;
  final Value value;
  final ExtraData extraData;

  const ObjectCubitState({
    @required this.hasValue,
    @required this.value,
    @required this.extraData,
  });

  ObjectCubitState<Value, ExtraData> toIdle() {
    return ObjectCubitIdle(extraData: extraData);
  }

  ObjectCubitState<Value, ExtraData> toUpdating() {
    return ObjectCubitUpdating(hasValue: hasValue, value: value, extraData: extraData);
  }

  ObjectCubitState<Value, ExtraData> toUpdateFailed({@required Object failure}) {
    return ObjectCubitUpdateFailed(
      hasValue: hasValue,
      value: value,
      failure: failure,
      extraData: extraData,
    );
  }

  ObjectCubitState<Value, ExtraData> toUpdated({@required bool hasValue, @required Value value}) {
    return ObjectCubitUpdated(hasValue: hasValue, value: value, extraData: extraData);
  }

  @override
  List<Object> get props => [hasValue, value];
}

class ObjectCubitIdle<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  ObjectCubitIdle({
    ExtraData extraData,
  }) : super(hasValue: null, value: null, extraData: extraData);
}

class ObjectCubitUpdating<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  ObjectCubitUpdating({
    @required bool hasValue,
    @required Value value,
    ExtraData extraData,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);
}

class ObjectCubitUpdateFailed<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  final Object failure;

  ObjectCubitUpdateFailed({
    @required bool hasValue,
    @required Value value,
    ExtraData extraData,
    this.failure,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);
}

class ObjectCubitUpdated<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  ObjectCubitUpdated({
    @required bool hasValue,
    @required Value value,
    ExtraData extraData,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);
}
