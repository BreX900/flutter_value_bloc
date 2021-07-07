import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class CloserProvider {
  Disposer get _disposer;
}

class Disposer extends DisposableEntry implements CloserProvider {
  final _entries = <DisposableEntry>[];

  void addSubscription(StreamSubscription subscription) {
    _entries.add(_DisposableSubscriptionEntry(subscription));
  }

  void removeSubscription(StreamSubscription subscription, {bool canClose = true}) {
    if (_entries.remove(_DisposableSubscriptionEntry(subscription))) {
      if (canClose) subscription.cancel();
    }
  }

  void addBloc(BlocBase bloc) {
    _entries.add(_DisposableBlocEntry(bloc));
  }

  void removeBloc(BlocBase bloc, {bool canClose = true}) {
    if (_entries.remove(_DisposableBlocEntry(bloc))) {
      if (canClose) bloc.close();
    }
  }

  @override
  void close() {
    _entries.forEach((entry) => entry.close());
  }

  @override
  Disposer get _disposer => this;
}

/// It allows you to automatic close [Cubit] with [CloseableBlocExtension]
/// It allows you to automatic unsubscribe to a [StreamSubscription] with [CloseableStreamSubscriptionExtension]
mixin BlocDisposer<State> on BlocBase<State> implements CloserProvider {
  @override
  final _disposer = Disposer();

  @override
  Future<void> close() {
    _disposer.close();
    return super.close();
  }
}

extension CloseableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  void addToCloser(CloserProvider closer) {
    closer._disposer.addSubscription(this);
  }

  void removeFromCloser(CloserProvider closer, {bool canClose = true}) {
    closer._disposer.removeSubscription(this, canClose: canClose);
  }
}

extension CloseableBlocExtension<State> on BlocBase<State> {
  void addToCloser(CloserProvider closer) {
    closer._disposer.addBloc(this);
  }

  void removeFromCloser(CloserProvider closer, {bool canClose = true}) {
    if (canClose) close();
    closer._disposer.removeBloc(this);
  }
}

abstract class DisposableEntry {
  void close();
}

class _DisposableSubscriptionEntry extends DisposableEntry {
  final StreamSubscription subscription;

  _DisposableSubscriptionEntry(this.subscription);

  @override
  void close() => subscription.cancel();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DisposableSubscriptionEntry &&
          runtimeType == other.runtimeType &&
          subscription == other.subscription;

  @override
  int get hashCode => subscription.hashCode;
}

class _DisposableBlocEntry extends DisposableEntry {
  final BlocBase bloc;

  _DisposableBlocEntry(this.bloc);

  @override
  void close() => bloc.close();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DisposableBlocEntry && runtimeType == other.runtimeType && bloc == other.bloc;

  @override
  int get hashCode => bloc.hashCode;
}

// ==================================================
//                   MODULAR CUBIT
// ==================================================

/// It allows you to combine several modules into a single cubit
mixin ModularCubitMixin<State> on BlocBase<State> {}

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
  LoadCubit? _loadCubit;
  LoadCubit get loadCubit {
    return _loadCubit ??= LoadCubit(loader: onLoading)..load();
  }

  void onLoading();

  /// See [LoadCubit.emitLoading]
  void emitLoading({required double progress}) => loadCubit.emitLoading(progress: progress);

  /// See [LoadCubit.emitLoadFailed]
  void emitLoadFailed({Object? failure}) => loadCubit.emitLoadFailed(failure: failure);

  /// See [LoadCubit.emitLoaded]
  void emitLoaded() => loadCubit.emitLoaded();

  @override
  Future<void> close() {
    loadCubit.close();
    return super.close();
  }
}
