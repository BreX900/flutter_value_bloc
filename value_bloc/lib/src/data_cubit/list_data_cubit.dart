import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:value_bloc/src/data_cubit/data_cubit.dart';

abstract class ListDataCubitBase<TFailure, TData> extends MultiDataCubit<TFailure, TData>
    with SingleDataCubit<MultiDataState<TFailure, TData>, TFailure, BuiltList<TData>> {
  ListDataCubitBase({
    required Equalizer<TData> equalizer,
  }) : super(
          state: MultiDataState(
            status: DataStatus.idle,
            failure: None(),
            length: null,
            allData: None(),
          ),
          equalizer: equalizer,
        );

  ListDataCubitBase._({
    required MultiDataState<TFailure, TData> state,
    required Equalizer<TData> equalizer,
  }) : super(
          state: state,
          equalizer: equalizer,
        );

  @override
  void emitRead({required BuiltList<TData> data}) {
    emit(state.copyWith(
      status: DataStatus.read,
      length: data.length,
      allData: Some(data.asMap().build().rebuild((b) => b.addAll(data.asMap()))),
    ));
  }
}

typedef ListDataReader = void Function();

class ListDataCubit<TFailure, TData> extends ListDataCubitBase<TFailure, TData> {
  late ListDataReader _reader;

  ListDataCubit({
    required Equalizer<TData> equalizer,
  }) : super._(
          state: MultiDataState(
            status: DataStatus.waiting,
            failure: None(),
            length: null,
            allData: None(),
          ),
          equalizer: equalizer,
        );

  void applyReader(ListDataReader reader) {
    _reader = reader;
    emitIdle();
  }

  @override
  void onReading() {
    emitReading();
    _reader();
  }
}
