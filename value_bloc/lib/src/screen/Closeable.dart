import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';
import 'package:value_bloc/value_bloc.dart';

/// It allows you to automatic unsubscribe to a [StreamSubscription] with [CloseableStreamSubscriptionExtension]
mixin CloseStreamSubscriptionModule<State> on Cubit<State> {
  final _compositeStream = CompositeSubscription();

  @override
  Future<void> close() {
    _compositeStream.dispose();
    return super.close();
  }
}

extension CloseableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  void addToContainer(CloseStreamSubscriptionModule container) {
    container._compositeStream.add(this);
  }

  void removeFromContainer(CloseStreamSubscriptionModule container) {
    container._compositeStream.remove(this);
  }
}

/// It allows you to automatic close [Cubit] with [CloseableCubitExtension]
mixin CloseCubitModule<State> on Cubit<State> {
  final _viewCubits = <Cubit>[];

  @override
  Future<void> close() {
    _viewCubits.forEach((c) => c.close());
    return super.close();
  }
}

extension CloseableCubitExtension<State> on Cubit<State> {
  void addToContainer(CloseCubitModule container) {
    container._viewCubits.add(this);
  }

  void removeFromContainer(CloseCubitModule container) {
    close();
    container._viewCubits.remove(container);
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

  @protected
  void emitLoading({@required double progress, ExtraData extraData}) {
    loadCubit.emitLoading(progress: progress, extraData: extraData);
  }

  @protected
  void emitLoadFailed({Object failure, ExtraData extraData}) {
    loadCubit.emitLoadFailed(failure: failure, extraData: extraData);
  }

  @protected
  void emitLoaded() => loadCubit.emitLoaded();

  @override
  Future<void> close() {
    loadCubit.close();
    return super.close();
  }
}
