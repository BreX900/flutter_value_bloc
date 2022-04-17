import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'mutation_bloc.g.dart';

@DataClass()
abstract class MutationState<TData> with _$MutationState<TData> {
  const MutationState._();

  bool get isIdle => this is IdleMutation<TData>;
  bool get isLoading => this is LoadingMutation<TData>;
  bool get isFailed => this is FailedMutation<TData>;
  bool get isSuccess => this is SuccessMutation<TData>;

  MutationState<TData> toLoading() => LoadingMutation();

  MutationState<TData> toError(Object error, StackTrace stackTrace) =>
      FailedMutation(error, stackTrace);

  MutationState<TData> toSuccess(TData data) => SuccessMutation(data);

  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  });

  R maybeMap<R>({
    R Function(IdleMutation<TData> state)? idle,
    R Function(LoadingMutation<TData> state)? loading,
    R Function(FailedMutation<TData> state)? failed,
    R Function(SuccessMutation<TData> state)? success,
    required R Function(MutationState<TData>) orElse,
  }) {
    return map(
      idle: idle ?? orElse,
      loading: loading ?? orElse,
      failed: failed ?? orElse,
      success: success ?? orElse,
    );
  }
}

@DataClass()
class IdleMutation<TData> extends MutationState<TData> with _$IdleMutation<TData> {
  const IdleMutation() : super._();

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return idle(this);
  }
}

@DataClass()
class LoadingMutation<TData> extends MutationState<TData> with _$LoadingMutation<TData> {
  LoadingMutation() : super._();

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return loading(this);
  }
}

@DataClass()
class FailedMutation<TData> extends MutationState<TData> with _$FailedMutation<TData> {
  final Object error;
  final StackTrace stackTrace;

  FailedMutation(this.error, this.stackTrace) : super._();

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return failed(this);
  }
}

@DataClass()
class SuccessMutation<TData> extends MutationState<TData> with _$SuccessMutation<TData> {
  final TData data;

  SuccessMutation(this.data) : super._();

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return success(this);
  }
}

abstract class MutationBloc<TData, TSuccess> extends Cubit<MutationState<TSuccess>> {
  MutationBloc() : super(IdleMutation<TSuccess>());

  factory MutationBloc.inline(
    Future<TSuccess> Function(TData arg) mutator,
  ) = _InlineMutationBloc<TData, TSuccess>;

  Future<TSuccess?> tryMutate(TData data) async {
    try {
      return await mutate(data);
    } catch (_) {
      return null;
    }
  }

  Future<TSuccess> mutate(TData data) async {
    if (state.isLoading) throw AlreadyMutatingError();

    emit(state.toLoading());

    try {
      final result = await onMutating(data);
      emit(state.toSuccess(result));
      return result;
    } catch (error, stackTrace) {
      onError(error, stackTrace);

      emit(state.toError(error, stackTrace));
      rethrow;
    }
  }

  @protected
  FutureOr<TSuccess> onMutating(TData data);
}

class _InlineMutationBloc<TArgs, TData> extends MutationBloc<TArgs, TData> {
  final Future<TData> Function(TArgs args) mutator;

  _InlineMutationBloc(this.mutator) : super();

  @override
  Future<TData> onMutating(TArgs args) => mutator(args);
}

class AlreadyMutatingError extends Error {
  @override
  String toString() => 'You cannot start a new mutation if one is already in progress';
}
