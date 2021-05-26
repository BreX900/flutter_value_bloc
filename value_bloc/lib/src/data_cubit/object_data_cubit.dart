import 'package:dartz/dartz.dart';
import 'package:value_bloc/src/data_cubit/data_cubit.dart';

abstract class ObjectDataCubitBase<TFailure, TData>
    extends DataCubit<SingleDataState<TFailure, TData>, TFailure, TData>
    with SingleDataCubit<SingleDataState<TFailure, TData>, TFailure, TData> {
  ObjectDataCubitBase._({required SingleDataState<TFailure, TData> state})
      : super(
          state: state,
        );

  ObjectDataCubitBase()
      : super(
          state: SingleDataState(
            status: DataStatus.idle,
            failure: None(),
            data: None(),
          ),
        );

  @override
  void emitRead(TData data) {
    emit(state.copyWith(status: DataStatus.read, data: Some(data)));
  }

  void emitCreating() {
    emit(state.copyWith(status: DataStatus.creating, data: None()));
  }

  void emitCreateFailed(TFailure failure) {
    emit(state.copyWith(status: DataStatus.createFailed, failure: Some(failure), data: None()));
  }

  void emitCreated(TData data) {
    emit(state.copyWith(status: DataStatus.created, data: Some(data)));
  }

  // Either<TFailure, TData> emitCreateResult(Either<TFailure, TData> result) {
  //   result.fold((failure) {
  //     emitCreateFailed(failure);
  //   }, (data) {
  //     emitCreated(data);
  //   });
  //   return result;
  // }

  void emitUpdating() {
    emit(state.copyWith(status: DataStatus.updating));
  }

  void emitUpdateFailed(TFailure failure) {
    emit(state.copyWith(status: DataStatus.updateFailed, failure: Some(failure)));
  }

  void emitUpdated(TData data) {
    emit(state.copyWith(status: DataStatus.updated, data: Some(data)));
  }

  // Either<TFailure, TData> emitUpdateResult(Either<TFailure, TData> result) {
  //   result.fold((failure) {
  //     emitUpdateFailed(failure);
  //   }, (data) {
  //     emitUpdated(data);
  //   });
  //   return result;
  // }

  void emitDeleting() {
    emit(state.copyWith(status: DataStatus.deleting));
  }

  void emitDeleteFailed(TFailure failure) {
    emit(state.copyWith(status: DataStatus.deleteFailed, failure: Some(failure)));
  }

  void emitDeleted() {
    emit(state.copyWith(status: DataStatus.deleted));
  }

  // Either<TFailure, TData> emitDeleteResult(Either<TFailure, TData> result) {
  //   result.fold((failure) {
  //     emitDeleteFailed(failure);
  //   }, (_) {
  //     emitDeleted();
  //   });
  //   return result;
  // }
}

typedef ObjectDataReader = void Function();

class ObjectDataCubit<TFailure, TData> extends ObjectDataCubitBase<TFailure, TData> {
  late ObjectDataReader _reader;

  ObjectDataCubit({ObjectDataReader? reader})
      : super._(
          state: SingleDataState(
            status: DataStatus.waiting,
            failure: None(),
            data: None(),
          ),
        ) {
    if (reader != null) _reader = reader;
  }

  void applyReader(ObjectDataReader reader) {
    _reader = reader;
    emitIdle();
  }

  @override
  void onReading() {
    emitReading();
    _reader();
  }
}
