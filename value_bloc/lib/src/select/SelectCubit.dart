import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';

part 'SelectState.dart';

typedef Equals<Value> = bool Function(Value a, Value b);

class SelectCubit<Value, ExtraData> extends Cubit<SelectCubitState<Value, ExtraData>> {
  final Equals<Value> _equals;

  SelectCubit({
    Equals<Value> equals,
  })  : _equals = equals ?? ((a, b) => a == b),
        super(SelectStateEmpty(oldSelection: null));

  void select(Iterable<Value> selection) {
    selection = selection.where((e) => state.selection.any((ee) => _equals(e, ee)));
    emit(state.toAdded(selection: state.selection.rebuild((b) => b.addAll(selection))));
  }

  void remove(Iterable<Value> selection) {
    emit(state.toRemoved(
      selection: state.selection.rebuild((b) {
        b.removeWhere((e) => selection.any((ee) => _equals(e, ee)));
      }),
    ));
  }

  void clear() {
    emit(state.toEmpty());
  }
}
