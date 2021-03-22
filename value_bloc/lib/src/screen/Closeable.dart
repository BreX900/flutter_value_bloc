import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';
import 'package:value_bloc/value_bloc.dart';

/// It allows you to automatic unsubscribe to a [StreamSubscription] with [CloseableStreamSubscriptionExtension]
mixin CloserStreamSubscriptionModule<State> on Cubit<State> {
  final _compositeStream = CompositeSubscription();

  @override
  Future<void> close() {
    _compositeStream.dispose();
    return super.close();
  }
}

extension CloseableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  void addToCloserCubit(CloserStreamSubscriptionModule module) {
    module._compositeStream.add(this);
  }

  void removeFromCloserCubit(CloserStreamSubscriptionModule module) {
    module._compositeStream.remove(this);
  }
}

/// It allows you to automatic close [Cubit] with [CloseableCubitExtension]
mixin CloserCubitModule<State> on Cubit<State> {
  final _cubits = <Cubit>[];

  @override
  Future<void> close() {
    _cubits.forEach((c) => c.close());
    return super.close();
  }
}

extension CloseableCubitExtension<State> on Cubit<State> {
  void addToCloserCubit(CloserCubitModule module) {
    module._cubits.add(this);
  }

  void removeFromCloserCubit(CloserCubitModule module) {
    close();
    module._cubits.remove(module);
  }
}

// ==================================================
//                   MODULAR CUBIT
// ==================================================

/// It allows you to combine several modules into a single cubit
mixin ModularCubitMixin<State> on Cubit<State> {}

/// See [ModularCubitMixin]
abstract class ModularCubit<State> extends Cubit<State> with ModularCubitMixin<State> {
  ModularCubit(State state) : super(state);
}

/// See [ModularCubitMixin]
abstract class ModularBloc<Event, State> extends Bloc<Event, State> with ModularCubitMixin<State> {
  ModularBloc(State initialState) : super(initialState);
}

// ==================================================
//                    MODULES
// ==================================================

mixin LoadCubitModule<ExtraData, State> on ModularCubitMixin<State> {
  LoadCubit _loadCubit;
  LoadCubit get loadCubit {
    return _loadCubit ??= LoadCubit(loader: onLoading)..load();
  }

  @protected
  void onLoading();

  /// See [LoadCubit.emitLoading]
  @protected
  void emitLoading({@required double progress}) => loadCubit.emitLoading(progress: progress);

  /// See [LoadCubit.emitLoadFailed]
  @protected
  void emitLoadFailed({Object failure}) => loadCubit.emitLoadFailed(failure: failure);

  /// See [LoadCubit.emitLoaded]
  @protected
  void emitLoaded() => loadCubit.emitLoaded();

  @override
  Future<void> close() {
    loadCubit.close();
    return super.close();
  }
}
