import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

abstract class SyncEvent<T> extends Equatable {
  final Object sender;

  SyncEvent(this.sender);
}

class InvalidSyncEvent<T> extends SyncEvent<T> {
  InvalidSyncEvent(Object sender) : super(sender);

  @override
  List<Object?> get props => [sender];
}

class CreatedSyncEvent<T> extends SyncEvent<T> {
  final T value;

  CreatedSyncEvent(Object sender, this.value) : super(sender);

  @override
  List<Object?> get props => [sender, value];
}

class UpdatedSyncEvent<T> extends SyncEvent<T> {
  final T value;

  UpdatedSyncEvent(Object sender, this.value) : super(sender);

  @override
  List<Object?> get props => [sender, value];
}

class ReplacedSyncEvent<T> extends SyncEvent<T> {
  final T previousValue;
  final T currentValue;

  ReplacedSyncEvent(Object sender, this.previousValue, this.currentValue) : super(sender);

  @override
  List<Object?> get props => [sender, previousValue, currentValue];
}

class DeletedSyncEvent<T> extends SyncEvent<T> {
  final T value;

  DeletedSyncEvent(Object sender, this.value) : super(sender);

  @override
  List<Object?> get props => [sender, value];
}

/// Allows different, loose coupled components to communicate/cooperate
/// through the publisher/subscriber pattern
///
/// Let's consider a set of operations:
/// CUD = create/update/delete
/// And a UI component:
/// MainBloc = Contains a value for UI
///
/// Problems:
/// What if a SecondaryBloc calls a use case and CUD a value? The MainBloc should reflect the action
///
/// Solutions:
/// 1. Events stream in Repository synchronization
///   Problems:
///   - When main bloc calls use case, the repository notify the event,
///     but the repository update value by event and not by use case result
///
/// 2. Bloc synchronization
///   When secondary bloc CUD the value notify CUD to main bloc
///   Problems:
///   - Secondary bloc is tightly coupled to the main bloc, since it needs an instance
///     of the main bloc to notify a event
///
/// 3. Bus Events ([SyncEventBus])
///   When a bloc update the value notify it in to Synchronizer.
///   The main bloc, if it is listening to the stream can update itself accordingly to the change
abstract class SyncEventBus<T> {
  SyncEventBus._();

  factory SyncEventBus() = _SingleSyncEventBus<T>;

  factory SyncEventBus.from(List<SyncEventBus<T>> list) = _MultiSyncEventBus<T>;

  Stream<SyncEvent<T>> get stream;

  /// Only emits events from these [senders]
  Stream<SyncEvent<T>> streamFromThese(List<Object> senders) {
    return stream.where((event) => senders.contains(event.sender));
  }

  /// Ignore the events of these [senders]
  Stream<SyncEvent<T>> streamFromOther(List<Object> senders) {
    return stream.where((event) => !senders.contains(event.sender));
  }

  /// It emits a successful invalid event
  void emitInvalidate(Object source) {
    add(InvalidSyncEvent(source));
  }

  /// It emits a successful creation event
  void emitCreate(Object source, T value) {
    add(CreatedSyncEvent(source, value));
  }

  /// It emits an event of successful update
  void emitUpdate(Object source, T value) {
    add(UpdatedSyncEvent(source, value));
  }

  /// It emits an event of successful replace
  void emitReplace(Object source, T previousValue, T currentValue) {
    add(ReplacedSyncEvent(source, previousValue, currentValue));
  }

  /// It emits an event of successful delete
  void emitDelete(Object source, T value) {
    add(DeletedSyncEvent(source, value));
  }

  void add(SyncEvent<T> event);
}

class _SingleSyncEventBus<T> extends SyncEventBus<T> {
  final _subject = StreamController<SyncEvent<T>>.broadcast(sync: true);

  _SingleSyncEventBus() : super._();

  @override
  void add(SyncEvent<T> event) => _subject.add(event);

  @override
  Stream<SyncEvent<T>> get stream => _subject.stream;
}

class _MultiSyncEventBus<T> extends SyncEventBus<T> {
  final List<SyncEventBus<T>> _list;

  _MultiSyncEventBus(this._list) : super._();

  @override
  void add(SyncEvent<T> event) => _list.forEach((syncBus) => syncBus.add(event));

  @override
  Stream<SyncEvent<T>> get stream => Rx.merge(_list.map((syncBus) => syncBus.stream));
}
