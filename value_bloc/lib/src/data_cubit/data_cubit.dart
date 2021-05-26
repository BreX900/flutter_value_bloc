import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils.dart';
import 'package:value_bloc/value_bloc.dart';

part 'data_state.dart';

abstract class DataCubit<TState extends DataState<TFailure, TData>, TFailure, TData>
    extends Cubit<TState> {
  DataCubit({required TState state}) : super(state);

  /// Clean the cubit (block all operations)
  void clean() {
    emitIdle();
  }

  void emitIdle() {
    emit(state.copyWith(status: DataStatus.idle) as TState);
  }

  void emitWaiting() {
    emit(state.copyWith(status: DataStatus.waiting) as TState);
  }

  // Object? _filter;
  //
  // void updateFilter(Object filter) {
  //   _filter = filter;
  //   emitIdle();
  // }
}

mixin SingleDataCubit<TState extends DataState<TFailure, TData>, TFailure, TData>
    on DataCubit<TState, TFailure, TData> {
  StreamSubscription? _readSub;

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

  void refresh() {
    if (state.status == DataStatus.reading) return;
    _readSub?.cancel();
    _readSub = null;
    emitIdle();
  }

  void onReading();

  void emitReading() {
    emit(state.copyWith(status: DataStatus.reading) as TState);
  }

  void emitReadFailed(TFailure failure) {
    emit(state.copyWith(status: DataStatus.readFailed, failure: Some(failure)) as TState);
  }

  void emitRead(TData data);

  void emitReadResults(Stream<Either<TFailure, TData>> results) {
    assert(_readSub == null);
    _readSub = results.listen((result) => result.fold(emitReadFailed, emitRead));
  }
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

  void emitUpdating() {
    emit(state.copyWith(status: DataStatus.updating));
  }

  void emitUpdateFailed(TFailure failure) {
    emit(state.copyWith(status: DataStatus.updateFailed, failure: Some(failure)));
  }

  void emitSingleUpdated(TData data) {
    emit(state.copyWith(
      status: DataStatus.updated,
      allData: Some(state.allData
          .rebuild((b) => b.updateAllValues((_, d) => _equalizer(d, data) ? data : d))),
    ));
  }

  @visibleForTesting
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
