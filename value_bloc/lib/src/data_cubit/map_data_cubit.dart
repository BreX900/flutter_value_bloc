import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:value_bloc/src/data_cubit/data_cubit.dart';
import 'package:value_bloc/src/utils.dart';

abstract class MapDataCubitBase<TFailure, TData>
    extends DataCubit<MultiDataState<TFailure, TData>, TFailure, BuiltList<TData>> {
  MapDataCubitBase()
      : super(
          state: MultiDataState(
            status: DataStatus.idle,
            failure: None(),
            length: null,
            allData: None(),
          ),
        );

  MapDataCubitBase._({required MultiDataState<TFailure, TData> state}) : super(state: state);

  void onReading(PageOffset offset);

  void read(PageOffset offset) {
    emitReading();
    onReading(offset);
  }

  void emitReading() {
    emit(state.copyWith(status: DataStatus.reading));
  }

  void emitReadFailed({required TFailure failure}) {
    emit(state.copyWith(status: DataStatus.readFailed, failure: Some(failure)));
  }

  void emitRead({required BuiltList<TData> data, required PageOffset offset}) {
    emit(state.copyWith(status: DataStatus.read, allData: Some(data.asMap().build())));
  }

  Either<TFailure, BuiltList<TData>> emitReadResult({
    required PageOffset offset,
    required Either<TFailure, BuiltList<TData>> result,
  }) {
    result.fold((failure) {
      emitReadFailed(failure: failure);
    }, (data) {
      emitRead(data: data, offset: offset);
    });
    return result;
  }
}

typedef GroupDataReader = void Function(PageOffset offset);

class MapDataCubit<TFailure, TData> extends MapDataCubitBase<TFailure, TData> {
  late GroupDataReader _reader;

  MapDataCubit()
      : super._(
          state: MultiDataState(
            status: DataStatus.waiting,
            failure: None(),
            length: null,
            allData: None(),
          ),
        );

  void applyReader(GroupDataReader reader) {
    _reader = reader;
    emitIdle();
  }

  @override
  void onReading(PageOffset offset) {
    emitReading();
    _reader(offset);
  }
}
