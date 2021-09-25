import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

abstract class DisposerProvider {
  Disposer get _disposer;
}

class Disposer extends Disposable implements DisposerProvider {
  final _entries = <Disposable>[];

  void add(Disposable disposable) {
    _entries.add(disposable);
  }

  void remove(Disposable disposable, {bool shouldDispose = true}) {
    if (_entries.remove(disposable)) {
      if (shouldDispose) disposable.dispose();
    }
  }

  @override
  Future<void> dispose() {
    return Future.wait(_entries.map((e) => e.dispose()));
  }

  @override
  Disposer get _disposer => this;
}

/// It allows you to automatic close [Cubit] with [CloseableBlocExtension]
/// It allows you to automatic unsubscribe to a [StreamSubscription] with [CloseableStreamSubscriptionExtension]
mixin BlocDisposer<State> on BlocBase<State> implements DisposerProvider {
  @override
  final _disposer = Disposer();

  @override
  Future<void> close() {
    _disposer.dispose();
    return super.close();
  }
}

extension DisposableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  Disposable asDisposable() => _DisposableSubscriptionEntry(this);
}

extension DisposableBlocExtension<State> on BlocBase<State> {
  Disposable asDisposable() => _DisposableBloc(this);
}

extension DisposableCompositeSubscriptionExtension on CompositeSubscription {
  Disposable asDisposable() => _DisposableCompositeSubscription(this);
}

abstract class Disposable {
  Future<void> dispose();

  void addTo(DisposerProvider disposer) => disposer._disposer.add(this);
  void removeFrom(DisposerProvider disposer, {bool canDispose = true}) =>
      disposer._disposer.remove(this, shouldDispose: canDispose);
}

class _DisposableSubscriptionEntry extends Disposable {
  final StreamSubscription subscription;

  _DisposableSubscriptionEntry(this.subscription);

  @override
  Future<void> dispose() => subscription.cancel();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DisposableSubscriptionEntry &&
          runtimeType == other.runtimeType &&
          subscription == other.subscription;

  @override
  int get hashCode => subscription.hashCode;
}

class _DisposableBloc extends Disposable {
  final BlocBase bloc;

  _DisposableBloc(this.bloc);

  @override
  Future<void> dispose() => bloc.close();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DisposableBloc && runtimeType == other.runtimeType && bloc == other.bloc;

  @override
  int get hashCode => bloc.hashCode;
}

class _DisposableCompositeSubscription extends Disposable {
  final CompositeSubscription subscriptions;

  _DisposableCompositeSubscription(this.subscriptions);

  @override
  Future<void> dispose() {
    subscriptions.dispose();
    return Future.value();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DisposableCompositeSubscription &&
          runtimeType == other.runtimeType &&
          subscriptions == other.subscriptions;

  @override
  int get hashCode => subscriptions.hashCode;
}
