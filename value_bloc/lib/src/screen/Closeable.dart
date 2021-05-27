import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class CloserProvider {
  Closer get _closer;
}

class Closer extends CloserEntry implements CloserProvider {
  final _entries = <CloserEntry>[];

  void addSubscription(StreamSubscription subscription) {
    _entries.add(_SubscriptionCloserEntry(subscription));
  }

  void removeSubscription(StreamSubscription subscription, {bool canClose = true}) {
    if (_entries.remove(_SubscriptionCloserEntry(subscription))) {
      if (canClose) subscription.cancel();
    }
  }

  void addBloc(BlocBase bloc) {
    _entries.add(_BlocCloserEntry(bloc));
  }

  void removeBloc(BlocBase bloc, {bool canClose = true}) {
    if (_entries.remove(_BlocCloserEntry(bloc))) {
      if (canClose) bloc.close();
    }
  }

  @override
  void close() {
    _entries.forEach((entry) => entry.close());
  }

  @override
  Closer get _closer => this;
}

/// It allows you to automatic close [Cubit] with [CloseableBlocExtension]
/// It allows you to automatic unsubscribe to a [StreamSubscription] with [CloseableStreamSubscriptionExtension]
mixin BlocCloser<State> on BlocBase<State> implements CloserProvider {
  @override
  final _closer = Closer();

  @override
  Future<void> close() {
    _closer.close();
    return super.close();
  }
}

extension CloseableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  void addToCloser(CloserProvider closer) {
    closer._closer.addSubscription(this);
  }

  void removeFromCloser(CloserProvider closer, {bool canClose = true}) {
    closer._closer.removeSubscription(this, canClose: canClose);
  }
}

extension CloseableBlocExtension<State> on BlocBase<State> {
  void addToCloser(CloserProvider closer) {
    closer._closer.addBloc(this);
  }

  void removeFromCloser(CloserProvider closer, {bool canClose = true}) {
    if (canClose) close();
    closer._closer.removeBloc(this);
  }
}

abstract class CloserEntry {
  void close();
}

class _SubscriptionCloserEntry extends CloserEntry {
  final StreamSubscription subscription;

  _SubscriptionCloserEntry(this.subscription);

  @override
  void close() => subscription.cancel();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SubscriptionCloserEntry &&
          runtimeType == other.runtimeType &&
          subscription == other.subscription;

  @override
  int get hashCode => subscription.hashCode;
}

class _BlocCloserEntry extends CloserEntry {
  final BlocBase bloc;

  _BlocCloserEntry(this.bloc);

  @override
  void close() => bloc.close();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BlocCloserEntry && runtimeType == other.runtimeType && bloc == other.bloc;

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
