import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';

abstract class Closeable {
  Future<void> close() async {}
}

abstract class CloseableCubit<State> extends Cubit<State> implements Closeable {
  CloseableCubit(State state) : super(state);
}

abstract class CloseableBloc<Event, State> extends Bloc<Event, State> implements Closeable {
  CloseableBloc(State initialState) : super(initialState);
}

mixin StreamSubscriptionContainer on Closeable {
  final _compositeStream = CompositeSubscription();

  @override
  Future<void> close() {
    _compositeStream.dispose();
    return super.close();
  }
}

mixin CubitContainer on Closeable {
  final _viewCubits = <Cubit>[];

  @override
  Future<void> close() {
    _viewCubits.forEach((c) => c.close());
    return super.close();
  }
}

mixin CubitLoadable on Closeable {
  LoadCubit get loadCubit;

  void emitLoading({@required double progress, Object data}) {
    loadCubit.notifyProgress(progress: progress, data: data);
  }

  void emitLoadFailed({Object failure, Object data}) {
    loadCubit.notifyFailure(failure: failure, data: data);
  }

  void emitLoaded() => loadCubit.notifySuccess();

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
