part of 'ListCubit.dart';

abstract class IterableCubitState<Value, ExtraData> with EquatableMixin {
  final int valuesCount;
  final BuiltMap<int, Value> allValues;
  final ExtraData extraData;

  IterableCubitState({
    @required this.valuesCount,
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
        valuesCount: valuesCount, allValues: allValues, extraData: extraData);
  }

  IterableCubitState<Value, ExtraData> toUpdated(
      {int valuesCount, BuiltMap<int, Value> allValues}) {
    return IterableCubitUpdated(
      valuesCount: valuesCount ?? this.valuesCount,
      allValues: allValues ?? this.allValues,
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toIdle() {
    return IterableCubitIdle(
      oldAllValues: allValues,
      allValues: allValues.rebuild((b) => b.clear()),
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toRemoved({@required BuiltMap<int, Value> allValues}) {
    return IterableCubitRemoved(
      valuesCount: valuesCount,
      allValues: allValues,
      extraData: extraData,
      oldAllValues: this.allValues,
    );
  }

  IterableCubitState<Value, ExtraData> toAdded({@required BuiltMap<int, Value> allValues}) {
    return IterableCubitAdded(
      valuesCount: valuesCount,
      allValues: allValues,
      extraData: extraData,
      oldAllValues: this.allValues,
    );
  }

  @override
  List<Object> get props => [valuesCount, allValues, extraData];
}

/// The job list is being updated
class IterableCubitUpdating<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitUpdating({
    int valuesCount,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}

class IterableCubitUpdateFailed<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final Object failure;

  IterableCubitUpdateFailed({
    int valuesCount,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
    this.failure,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);

  @override
  List<Object> get props => super.props..add(failure);
}

/// The job list has been updated
/// [ListCubit] The old values have been replaced by the new ones
/// [MultiCubit] New values have been added to the previous values
class IterableCubitUpdated<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitUpdated({
    int valuesCount,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}

/// All values have been removed
/// [ListCubit] All values have been removed
/// [MultiCubit] All values have been removed and you call fetch when receive this state
///              it is a initial State
class IterableCubitIdle<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final BuiltMap<int, Value> oldAllValues;

  IterableCubitIdle({
    @required BuiltMap<int, Value> allValues,
    @required ExtraData extraData,
    @required this.oldAllValues,
  }) : super(valuesCount: null, allValues: allValues, extraData: extraData);
}

class IterableCubitAdded<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final BuiltMap<int, Value> oldAllValues;

  IterableCubitAdded({
    int valuesCount,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
    @required this.oldAllValues,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}

class IterableCubitRemoved<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final BuiltMap<int, Value> oldAllValues;

  IterableCubitRemoved({
    int valuesCount,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
    @required this.oldAllValues,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}
