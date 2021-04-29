import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

part 'cud_state.dart';

abstract class CudCubit<RawValue, PartialValue, Value>
    extends Cubit<CudCubitState<RawValue, PartialValue, Value>> {
  CudCubit() : super(CudCubitIdle());

  void create(Iterable<RawValue> values) {
    final list = values.toBuiltList();
    emit(state.toCreating(values: list));
    onCreating(list);
  }

  void update(Iterable<PartialValue> values) {
    final list = values.toBuiltList();
    emit(state.toUpdating(values: list));
    onUpdating(list);
  }

  void delete(Iterable<Value> values) {
    final list = values.toBuiltList();
    emit(state.toDeleting(values: list));
    onDeleting(list);
  }

  void onCreating(BuiltList<RawValue> values);

  void onUpdating(BuiltList<PartialValue> values);

  void onDeleting(BuiltList<Value> values);

  void emitCreated(Iterable<Value> values) {
    emit(state.toCreated(values: values.toBuiltList()));
  }

  void emitUpdated(Iterable<Value> values) {
    emit(state.toUpdated(values: values.toBuiltList()));
  }

  void emitDeleted(Iterable<Value> values) {
    emit(state.toDeleted(values: values.toBuiltList()));
  }
}
