import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:value_bloc/src/utils.dart';
import 'package:value_bloc/value_bloc.dart';

part 'data_state.dart';

abstract class DataCubit<TState extends DataState<TFailure, TData>, TFailure, TData>
    extends Cubit<TState> {
  DataCubit({required TState state}) : super(state);

  void emitIdle() {
    emit(state.copyWith(status: DataStatus.idle) as TState);
  }

  void emitWaiting() {
    emit(state.copyWith(status: DataStatus.waiting) as TState);
  }
}

mixin SingleDataCubit<TState extends DataState<TFailure, TData>, TFailure, TData>
    on DataCubit<TState, TFailure, TData> {
  Future<Either<TFailure, TData>> read() {
    emitReading();
    onReading();
    return stream.firstWhere((state) {
      return state.status.isCompleted;
    }).then((state) {
      if (state.hasFailure) {
        return Left(state.failure);
      } else if (state.hasData) {
        return Right(state.data);
      }
      throw '...';
    });
  }

  void onReading();

  void emitReading() {
    emit(state.copyWith(status: DataStatus.reading) as TState);
  }

  void emitReadFailed(TFailure failure) {
    emit(state.copyWith(status: DataStatus.readFailed, failure: Some(failure)) as TState);
  }

  void emitRead(TData data);

  // Either<TFailure, TData> emitReadResults(Stream<Either<TFailure, TData>> results) {
  //   results.listen((result) => result.fold(emitReadFailed, emitRead));
  //   return result;
  // }
}

typedef Equalizer<T> = bool Function(T a, T b);

typedef Indexer<T> = int Function(T value);

abstract class MultiDataCubit<TFailure, TData>
    extends DataCubit<MultiDataState<TFailure, TData>, TFailure, BuiltList<TData>> with BlocCloser {
  final _delegators = <DelegateEntry>[];

  final Equalizer<TData> _equalizer;

  MultiDataCubit({
    required MultiDataState<TFailure, TData> state,
    required Equalizer<TData> equalizer,
  })  : _equalizer = equalizer,
        super(
            state: MultiDataState(
          status: DataStatus.idle,
          failure: None(),
          length: null,
          allData: None(),
        ));

  DC connectDelegator<DC extends ObjectDataCubit<TFailure, TData>>(DC dataCubit) {
    dataCubit.stream.listen((singleDataState) {
      if (state.notHasData) return;
      switch (singleDataState.status) {
        case DataStatus.created:
          emit(state.copyWith(
            allData: state._allData.map((a) {
              return a.rebuild((b) => b[a.keys.last + 1] = singleDataState.data);
            }),
          ));
          break;
        case DataStatus.read:
        case DataStatus.updated:
          emit(state.copyWith(
            allData: state._allData.map((a) {
              final entry =
                  a.entries.firstWhere((entry) => _equalizer(entry.value, singleDataState.data));
              return a.rebuild((b) => b[entry.key] = singleDataState.data);
            }),
          ));
          break;
        case DataStatus.deleted:
          emit(state.copyWith(
            allData: state._allData.map((a) {
              return a.rebuild(
                  (b) => b.removeWhere((_, value) => _equalizer(value, singleDataState.data)));
            }),
          ));
          break;
        default:
          break;
      }
    }, onDone: () {
      _delegators;
    }).addToCloser(this);
    return dataCubit;
  }
}

class DelegateEntry {
  final ObjectDataCubit objectDataCubit;
  final StreamSubscription subscription;

  DelegateEntry(this.objectDataCubit, this.subscription);

  void close() {
    objectDataCubit.close();
    subscription.cancel();
  }
}
