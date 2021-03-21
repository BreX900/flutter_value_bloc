part of 'ObjectCubit.dart';

abstract class ObjectCubitState<Value, ExtraData> extends Equatable {
  final bool hasValue;
  final Value value;
  final ExtraData extraData;

  ObjectCubitState({
    @required this.hasValue,
    @required this.value,
    @required this.extraData,
  });

  Value get _oldValue {
    final state = this;
    if (state is ObjectCubitUpdating<Value, ExtraData>) {
      return state.oldValue;
    } else {
      return state.value;
    }
  }

  ObjectCubitState<Value, ExtraData> toUpdating() {
    return ObjectCubitUpdating(
      hasValue: null,
      value: null,
      extraData: extraData,
      oldValue: _oldValue,
    );
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
    return ObjectCubitUpdated(
      hasValue: hasValue,
      value: value,
      extraData: extraData,
      oldValue: _oldValue,
    );
  }

  ObjectCubitState<Value, ExtraData> copyWith({Optional<ExtraData> extraData = const Optional()}) {
    final state = this;
    final currentExtraData = extraData.ifAbsent(this.extraData);
    if (state is ObjectCubitUpdating<Value, ExtraData>) {
      return ObjectCubitUpdating(
        hasValue: hasValue,
        value: value,
        extraData: currentExtraData,
        oldValue: state.oldValue,
      );
    } else if (state is ObjectCubitUpdateFailed<Value, ExtraData>) {
      return ObjectCubitUpdateFailed(
        hasValue: hasValue,
        value: value,
        extraData: currentExtraData,
        failure: state.failure,
      );
    } else if (state is ObjectCubitUpdated<Value, ExtraData>) {
      return ObjectCubitUpdated(
        hasValue: hasValue,
        value: value,
        extraData: currentExtraData,
        oldValue: state.oldValue,
      );
    } else {
      throw 'Not known "${this}" state';
    }
  }

  @override
  List<Object> get props => [hasValue, value, extraData];
}

class ObjectCubitUpdating<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  final Value oldValue;

  ObjectCubitUpdating({
    bool hasValue,
    Value value,
    ExtraData extraData,
    @required this.oldValue,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);

  @override
  List<Object> get props => super.props..add(oldValue);
}

class ObjectCubitUpdateFailed<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  final Object failure;

  ObjectCubitUpdateFailed({
    @required bool hasValue,
    @required Value value,
    ExtraData extraData,
    this.failure,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);

  @override
  List<Object> get props => super.props..add(failure);
}

class ObjectCubitUpdated<Value, ExtraData> extends ObjectCubitState<Value, ExtraData> {
  final Value oldValue;

  ObjectCubitUpdated({
    @required bool hasValue,
    @required Value value,
    ExtraData extraData,
    @required this.oldValue,
  }) : super(hasValue: hasValue, value: value, extraData: extraData);

  @override
  List<Object> get props => super.props..add(oldValue);
}
