import 'dart:async';

import 'package:value_bloc/src_3/sync_event_bus.dart';

abstract class Syncer<T, R> extends StreamTransformerBase<SyncEvent<T>, R> {
  const Syncer();

  @override
  Stream<R> bind(Stream<SyncEvent<T>> eventStream) {
    return eventStream.asyncExpand(mapEvent);
  }

  Stream<R> mapEvent(SyncEvent<T> event) {
    if (event is InvalidSyncEvent<T>) {
      return mapInvalidEvent(event);
    } else if (event is CreatedSyncEvent<T>) {
      return mapCreatedEvent(event);
    } else if (event is UpdatedSyncEvent<T>) {
      return mapUpdatedEvent(event);
    } else if (event is ReplacedSyncEvent<T>) {
      return mapReplacedEvent(event);
    } else if (event is DeletedSyncEvent<T>) {
      return mapDeletedEvent(event);
    } else {
      throw UnimplementedError('$event');
    }
  }

  Stream<R> mapInvalidEvent(InvalidSyncEvent<T> event);

  Stream<R> mapCreatedEvent(CreatedSyncEvent<T> event);

  Stream<R> mapUpdatedEvent(UpdatedSyncEvent<T> event);

  Stream<R> mapReplacedEvent(ReplacedSyncEvent<T> event);

  Stream<R> mapDeletedEvent(DeletedSyncEvent<T> event);
}
