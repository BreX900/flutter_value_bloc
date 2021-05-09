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
  void emitRead({required TData data}) {
    emit(state.copyWith(status: DataStatus.read, data: Some(data)));
  }

  void emitCreating() {
    emit(state.copyWith(status: DataStatus.creating, data: None()));
  }

  void emitCreateFailed({required TFailure failure}) {
    emit(state.copyWith(status: DataStatus.createFailed, failure: Some(failure), data: None()));
  }

  void emitCreated({required TData data}) {
    emit(state.copyWith(status: DataStatus.created, data: Some(data)));
  }

  Either<TFailure, TData> emitCreateResult(Either<TFailure, TData> result) {
    result.fold((failure) {
      emitCreateFailed(failure: failure);
    }, (data) {
      emitCreated(data: data);
    });
    return result;
  }

  void emitUpdating() {
    emit(state.copyWith(status: DataStatus.updating));
  }

  void emitUpdateFailed({required TFailure failure}) {
    emit(state.copyWith(status: DataStatus.updateFailed, failure: Some(failure)));
  }

  void emitUpdated({required TData data}) {
    emit(state.copyWith(status: DataStatus.updated, data: Some(data)));
  }

  Either<TFailure, TData> emitUpdateResult(Either<TFailure, TData> result) {
    result.fold((failure) {
      emitUpdateFailed(failure: failure);
    }, (data) {
      emitUpdated(data: data);
    });
    return result;
  }

  void emitDeleting() {
    emit(state.copyWith(status: DataStatus.deleting));
  }

  void emitDeleteFailed({required TFailure failure}) {
    emit(state.copyWith(status: DataStatus.deleteFailed, failure: Some(failure)));
  }

  void emitDeleted() {
    emit(state.copyWith(status: DataStatus.deleted));
  }

  Either<TFailure, TData> emitDeleteResult(Either<TFailure, TData> result) {
    result.fold((failure) {
      emitDeleteFailed(failure: failure);
    }, (_) {
      emitDeleted();
    });
    return result;
  }

  // map() {
  //   return ObjectDataCubit(reader: () async {
  //     final res = await read();
  //   })
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
