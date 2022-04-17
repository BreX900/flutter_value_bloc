import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'job_bloc.g.dart';

@DataClass()
abstract class Job<T> with _$Job<T> {
  const Job._();

  bool get isIdle => this is IdleJob<T>;
  bool get isLoading => this is LoadingJob<T>;
  bool get isError => this is ErrorJob<T>;
  bool get isSuccess => this is SuccessJob<T>;

  Job<T> toLoading() => LoadingJob();

  Job<T> toError(Object error, StackTrace stackTrace) => ErrorJob(error, stackTrace);

  Job<T> toSuccess(T data) => SuccessJob(data);

  R map<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(T value) success,
  });

  R maybeMap<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(Object error, StackTrace st)? error,
    R Function(T value)? success,
    required R Function() orElse,
  }) {
    return map(idle: () {
      return (idle ?? orElse)();
    }, loading: () {
      return (loading ?? orElse)();
    }, error: (e, st) {
      return error != null ? error(e, st) : orElse();
    }, success: (data) {
      return success != null ? success(data) : orElse();
    });
  }
}

@DataClass()
class IdleJob<T> extends Job<T> with _$IdleJob<T> {
  const IdleJob() : super._();

  @override
  R map<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(T value) success,
  }) {
    return idle();
  }
}

@DataClass()
class LoadingJob<T> extends Job<T> with _$LoadingJob<T> {
  LoadingJob() : super._();

  @override
  R map<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(T value) success,
  }) {
    return loading();
  }
}

@DataClass()
class ErrorJob<T> extends Job<T> with _$ErrorJob<T> {
  final Object error;
  final StackTrace stackTrace;

  ErrorJob(this.error, this.stackTrace) : super._();

  @override
  R map<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(T value) success,
  }) {
    return error(this.error, stackTrace);
  }
}

@DataClass()
class SuccessJob<T> extends Job<T> with _$SuccessJob<T> {
  final T value;

  SuccessJob(this.value) : super._();

  @override
  R map<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(T value) success,
  }) {
    return success(this.value);
  }
}

abstract class JobBloc<TData, TSuccess> extends Cubit<Job<TSuccess>> {
  JobBloc() : super(IdleJob<TSuccess>());

  Future<TSuccess?> tryWork(TData data) async {
    try {
      return await work(data);
    } catch (_) {
      return null;
    }
  }

  Future<TSuccess> work(TData data) async {
    if (state.isLoading) throw AlreadyWorkingError();

    emit(state.toLoading());

    try {
      final result = await onWorking(data);
      emit(state.toSuccess(result));
      return result;
    } catch (error, stackTrace) {
      onError(error, stackTrace);

      emit(state.toError(error, stackTrace));
      rethrow;
    }
  }

  @protected
  FutureOr<TSuccess> onWorking(TData data);
}

class AlreadyWorkingError extends Error {
  @override
  String toString() => 'You cannot start a new job if one is already in progress';
}
