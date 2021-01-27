part of 'ObjectCubit.dart';

abstract class ObjectState<Value, ExtraData> extends Equatable {
  final bool hasValue;
  final Value value;
  final ExtraData extraData;

  const ObjectState({
    @required this.hasValue,
    @required this.value,
    @required this.extraData,
  });

  ObjectState<Value, ExtraData> toIdle() {
    return ObjectCubitIdle(extraData: extraData);
  }

  ObjectState<Value, ExtraData> toUpdating() {
    return ObjectCubitUpdating(hasValue: hasValue, value: value, extraData: extraData);
  }

  ObjectState<Value, ExtraData> toUpdateFailed({@required Object failure}) {
    return ObjectCubitUpdateFailed(
      hasValue: hasValue,
      value: value,
      failure: failure,
      extraData: extraData,
    );
  }

  ObjectState<Value, ExtraData> toUpdated({@required bool hasValue, @required Value value}) {
    return ObjectCubitUpdated(hasValue: hasValue, value: value, extraData: extraData);
  }

  @override
  List<Object> get props => [hasValue, value];
}

class ObjectCubitIdle<Value, ExtraData> extends ObjectState<Value, ExtraData> {
  ObjectCubitIdle({
    @required ExtraData extraData,
  }) : super(hasValue: null, value: null, extraData: extraData);
}

class ObjectCubitUpdating<Value, ExtraData> extends ObjectState<Value, ExtraData> {
  ObjectCubitUpdating({
    @required bool hasValue,
    @required Value value,
    @required ExtraData extraData,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);
}

class ObjectCubitUpdateFailed<Value, ExtraData> extends ObjectState<Value, ExtraData> {
  final Object failure;

  ObjectCubitUpdateFailed({
    @required bool hasValue,
    @required Value value,
    @required ExtraData extraData,
    @required this.failure,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);
}

class ObjectCubitUpdated<Value, ExtraData> extends ObjectState<Value, ExtraData> {
  ObjectCubitUpdated({
    @required bool hasValue,
    @required Value value,
    @required ExtraData extraData,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);
}
