part of 'SelectCubit.dart';

abstract class SelectCubitState<Value, ExtraData> {
  final BuiltList<Value> oldSelection;
  final BuiltList<Value> selection;

  const SelectCubitState({
    @required this.oldSelection,
    @required this.selection,
  });

  SelectCubitState<Value, ExtraData> toEmpty() => SelectStateEmpty(oldSelection: selection);

  SelectCubitState<Value, ExtraData> toAdded({@required BuiltList<Value> selection}) {
    return SelectStateAdded(oldSelection: this.selection, selection: selection);
  }

  SelectCubitState<Value, ExtraData> toRemoved({@required BuiltList<Value> selection}) {
    return SelectStateRemoved(oldSelection: this.selection, selection: selection);
  }
}

class SelectStateEmpty<Value, ExtraData> extends SelectCubitState<Value, ExtraData> {
  SelectStateEmpty({
    @required BuiltList<Value> oldSelection,
  }) : super(oldSelection: oldSelection, selection: BuiltList<Value>());
}

class SelectStateAdded<Value, ExtraData> extends SelectCubitState<Value, ExtraData> {
  SelectStateAdded({
    @required BuiltList<Value> selection,
    @required BuiltList<Value> oldSelection,
  }) : super(oldSelection: oldSelection, selection: selection);
}

class SelectStateRemoved<Value, ExtraData> extends SelectCubitState<Value, ExtraData> {
  SelectStateRemoved({
    @required BuiltList<Value> selection,
    @required BuiltList<Value> oldSelection,
  }) : super(oldSelection: oldSelection, selection: selection);
}
