part of 'IterableCubit.dart';

abstract class IterableCubitState<Value, ExtraData> with EquatableMixin {
  final int length;
  final BuiltMap<int, Value> allValues;
  final ExtraData extraData;

  IterableCubitState({
    @required this.length,
    @required this.allValues,
    @required this.extraData,
  });

  BuiltList<Value> _values;
  BuiltList<Value> get values {
    if (_values == null) {
      final values = <Value>[];
      for (var i = 0; allValues.containsKey(i); i++) {
        values.add(allValues[i]);
      }
      _values = values.toBuiltList();
    }
    return _values;
  }

  IterableCubitState<Value, ExtraData> toUpdating() {
    return IterableCubitUpdating(
      length: length,
      allValues: allValues,
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toUpdateFailed({Object failure}) {
    return IterableCubitUpdateFailed(
      length: length,
      allValues: allValues,
      extraData: extraData,
      failure: failure,
    );
  }

  IterableCubitState<Value, ExtraData> toUpdated({
    int length,
    BuiltMap<int, Value> allValues,
  }) {
    return IterableCubitUpdated(
      length: length ?? this.length,
      allValues: allValues ?? this.allValues,
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toIdle() {
    return IterableCubitIdle(
      allValues: allValues.rebuild((b) => b.clear()),
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toRemoved({@required BuiltMap<int, Value> allValues}) {
    return IterableCubitRemoved(
      length: length,
      allValues: allValues,
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toAdded({@required BuiltMap<int, Value> allValues}) {
    return IterableCubitAdded(
      length: length,
      allValues: allValues,
      extraData: extraData,
    );
  }

  @override
  List<Object> get props => [length, allValues, extraData];
}

/// The job list is being updated
class IterableCubitUpdating<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitUpdating({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

class IterableCubitUpdateFailed<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final Object failure;

  IterableCubitUpdateFailed({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
    this.failure,
  }) : super(length: length, allValues: allValues, extraData: extraData);

  @override
  List<Object> get props => super.props..add(failure);
}

/// The job list has been updated
/// [ListCubit] The old values have been replaced by the new ones
/// [MultiCubit] New values have been added to the previous values
class IterableCubitUpdated<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitUpdated({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

/// All values have been removed
/// [ListCubit] All values have been removed
/// [MultiCubit] All values have been removed and you call fetch when receive this state
///              it is a initial State
class IterableCubitIdle<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitIdle({
    @required BuiltMap<int, Value> allValues,
    @required ExtraData extraData,
  }) : super(length: null, allValues: allValues, extraData: extraData);
}

class IterableCubitAdded<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitAdded({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

class IterableCubitRemoved<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitRemoved({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}
