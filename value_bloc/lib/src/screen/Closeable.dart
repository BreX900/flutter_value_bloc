import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';
import 'package:value_bloc/value_bloc.dart';

mixin ModularCubitMixin<State> on Cubit<State> {}

abstract class ModularCubit<State> extends Cubit<State> with ModularCubitMixin<State> {
  ModularCubit(State state) : super(state);
}

abstract class ModularBloc<Event, State> extends Bloc<Event, State> with ModularCubitMixin<State> {
  ModularBloc(State initialState) : super(initialState);
}

mixin StreamSubscriptionContainer<State> on ModularCubitMixin<State> {
  final _compositeStream = CompositeSubscription();

  @override
  Future<void> close() {
    _compositeStream.dispose();
    return super.close();
  }
}

mixin CubitContainer<State> on ModularCubitMixin<State> {
  final _viewCubits = <Cubit>[];

  @override
  Future<void> close() {
    _viewCubits.forEach((c) => c.close());
    return super.close();
  }
}

mixin CubitLoadable<ExtraData, State> on ModularCubitMixin<State> {
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

extension CloseableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  void addToContainer(StreamSubscriptionContainer container) {
    container._compositeStream.add(this);
  }

  void removeFromContainer(StreamSubscriptionContainer container) {
    container._compositeStream.remove(this);
  }
}

extension ClosealbeCubitExtension<State> on Cubit<State> {
  void addToContainer(CubitContainer container) {
    container._viewCubits.add(this);
  }

  void removeFromContainer(CubitContainer container) {
    close();
    container._viewCubits.remove(container);
  }
}
