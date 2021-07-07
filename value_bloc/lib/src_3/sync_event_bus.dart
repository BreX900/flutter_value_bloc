import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class SyncEvent<T> extends Equatable {
  final Object sender;

  SyncEvent(this.sender);
}

class CreateSyncEvent<T> extends SyncEvent<T> {
  final T value;

  CreateSyncEvent(Object sender, this.value) : super(sender);

  @override
  List<Object?> get props => [sender, value];
}

class UpdateSyncEvent<T> extends SyncEvent<T> {
  final T previousValue;
  final T currentValue;

  UpdateSyncEvent(Object sender, this.previousValue, this.currentValue) : super(sender);

  @override
  List<Object?> get props => [sender, previousValue, currentValue];
}

class DeleteSyncEvent<T> extends SyncEvent<T> {
  final T value;

  DeleteSyncEvent(Object sender, this.value) : super(sender);

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
class SyncEventBus<T> {
  final _subject = StreamController<SyncEvent<T>>.broadcast(sync: true);

  Stream<SyncEvent<T>> get stream => _subject.stream;

  /// Filters the events by [receiver]
  Stream<SyncEvent<T>> othersStream(Object receiver) {
    return stream.where((event) => event.sender != receiver);
  }

  /// It emits a successful creation event
  void emitCreate(Object source, T value) {
    _subject.add(CreateSyncEvent(source, value));
  }

  /// It emits an event of successful update
  void emitUpdate(Object source, T previousValue, T currentValue) {
    _subject.add(UpdateSyncEvent(source, previousValue, currentValue));
  }

  /// It emits an event of successful delete
  void emitDelete(Object source, T value) {
    _subject.add(DeleteSyncEvent(source, value));
  }
}
