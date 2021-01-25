part of 'ListCubit.dart';

abstract class ListCubitState<Value, ExtraData> with EquatableMixin {
  final int valuesCount;
  final BuiltList<Value> allValues;
  final ExtraData extraData;

  ListCubitState({
    @required this.valuesCount,
    @required this.allValues,
    @required this.extraData,
  });

  BuiltList<Value> _values;
  BuiltList<Value> get values {
    return _values ??= allValues.takeWhile((value) => value != null).toBuiltList();
  }

  ListCubitState<Value, ExtraData> toUpdating() {
    return ListCubitUpdating(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
  }

  ListCubitState<Value, ExtraData> toUpdated({int valuesCount, BuiltList<Value> allValues}) {
    return ListCubitUpdated(
      valuesCount: valuesCount ?? this.valuesCount,
      allValues: allValues ?? this.allValues,
      extraData: extraData,
    );
  }

  ListCubitState<Value, ExtraData> toEmpty() {
    return ListCubitEmpty(
      oldAllValues: allValues,
      allValues: allValues.rebuild((b) => b.clear()),
      extraData: extraData,
    );
  }

  ListCubitState<Value, ExtraData> toRemoved({@required BuiltList<Value> allValues}) {
    return ListCubitRemoved(
      valuesCount: valuesCount,
      allValues: allValues,
      extraData: extraData,
      oldAllValues: this.allValues,
    );
  }

  ListCubitState<Value, ExtraData> toAdded({@required BuiltList<Value> allValues}) {
    return ListCubitAdded(
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
class ListCubitUpdating<Value, ExtraData> extends ListCubitState<Value, ExtraData> {
  ListCubitUpdating({
    int valuesCount,
    @required BuiltList<Value> allValues,
    ExtraData extraData,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}

class ListCubitUpdateFailed<Value, ExtraData> extends ListCubitState<Value, ExtraData> {
  final Object failure;

  ListCubitUpdateFailed({
    int valuesCount,
    @required BuiltList<Value> allValues,
    ExtraData extraData,
    this.failure,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);

  @override
  List<Object> get props => super.props..add(failure);
}

/// The job list has been updated
/// [ListCubit] The old values have been replaced by the new ones
/// [MultiCubit] New values have been added to the previous values
class ListCubitUpdated<Value, ExtraData> extends ListCubitState<Value, ExtraData> {
  ListCubitUpdated({
    int valuesCount,
    @required BuiltList<Value> allValues,
    ExtraData extraData,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}

/// All values have been removed
/// [ListCubit] All values have been removed
/// [MultiCubit] All values have been removed and you call fetch when receive this state
///              it is a initial State
class ListCubitEmpty<Value, ExtraData> extends ListCubitState<Value, ExtraData> {
  final BuiltList<Value> oldAllValues;

  ListCubitEmpty({
    @required this.oldAllValues,
    @required BuiltList<Value> allValues,
    @required ExtraData extraData,
  }) : super(valuesCount: null, allValues: allValues, extraData: extraData);
}

class ListCubitAdded<Value, ExtraData> extends ListCubitState<Value, ExtraData> {
  final BuiltList<Value> oldAllValues;

  ListCubitAdded({
    int valuesCount,
    @required BuiltList<Value> allValues,
    ExtraData extraData,
    @required this.oldAllValues,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}

class ListCubitRemoved<Value, ExtraData> extends ListCubitState<Value, ExtraData> {
  final BuiltList<Value> oldAllValues;

  ListCubitRemoved({
    int valuesCount,
    @required BuiltList<Value> allValues,
    ExtraData extraData,
    @required this.oldAllValues,
  }) : super(valuesCount: valuesCount, allValues: allValues, extraData: extraData);
}
