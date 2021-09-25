import 'package:value_bloc/src/data_blocs.dart';
import 'package:value_bloc/src/utils/sync_event_bus.dart';
import 'package:value_bloc/src/utils/syncer.dart';

enum DataBlocSyncerAction { invalidate, none }

class DataBlocSyncerActions {
  final DataBlocSyncerAction? created;
  final DataBlocSyncerAction? updated;
  final DataBlocSyncerAction? replaced;
  final DataBlocSyncerAction? deleted;

  const DataBlocSyncerActions({
    this.created,
    this.updated,
    this.replaced,
    this.deleted,
  });

  const DataBlocSyncerActions.none({
    this.created = DataBlocSyncerAction.none,
    this.updated = DataBlocSyncerAction.none,
    this.replaced = DataBlocSyncerAction.none,
    this.deleted = DataBlocSyncerAction.none,
  });

  const DataBlocSyncerActions.invalidate({
    this.created = DataBlocSyncerAction.invalidate,
    this.updated = DataBlocSyncerAction.invalidate,
    this.replaced = DataBlocSyncerAction.invalidate,
    this.deleted = DataBlocSyncerAction.invalidate,
  });
}

extension DataBlocSyncerActionExt on DataBlocSyncerAction? {
  Stream<DataBlocEmission<TFailure, TValue>>
      bind<TEvent extends SyncEvent<TValue>, TFailure, TValue>(
    TEvent event,
    Stream<DataBlocEmission<TFailure, TValue>> Function(TEvent event) mapper,
  ) async* {
    switch (this) {
      case DataBlocSyncerAction.invalidate:
        yield InvalidateDataBloc();
        break;
      case DataBlocSyncerAction.none:
        break;
      case null:
        yield* mapper(event);
        break;
    }
  }
}

abstract class DataBlocSyncer<TFailure, TValue>
    extends Syncer<TValue, DataBlocEmission<TFailure, TValue>> {
  final DataBlocSyncerActions actions;

  const DataBlocSyncer({
    this.actions = const DataBlocSyncerActions(),
  });

  @override
  Stream<DataBlocEmission<TFailure, TValue>> mapInvalidEvent(
      InvalidSyncEvent<TValue> event) async* {
    yield InvalidateDataBloc();
  }

  @override
  Stream<DataBlocEmission<TFailure, TValue>> mapCreatedEvent(CreatedSyncEvent<TValue> event) {
    return actions.created.bind(event, onMapCreatedEvent);
  }

  @override
  Stream<DataBlocEmission<TFailure, TValue>> mapUpdatedEvent(UpdatedSyncEvent<TValue> event) {
    return actions.updated.bind(event, onMapUpdatedEvent);
  }

  @override
  Stream<DataBlocEmission<TFailure, TValue>> mapReplacedEvent(ReplacedSyncEvent<TValue> event) {
    return actions.replaced.bind(event, onMapReplacedEvent);
  }

  @override
  Stream<DataBlocEmission<TFailure, TValue>> mapDeletedEvent(DeletedSyncEvent<TValue> event) {
    return actions.deleted.bind(event, onMapDeletedEvent);
  }

  Stream<DataBlocEmission<TFailure, TValue>> onMapCreatedEvent(CreatedSyncEvent<TValue> event);

  Stream<DataBlocEmission<TFailure, TValue>> onMapUpdatedEvent(
      UpdatedSyncEvent<TValue> event) async* {
    yield UpdateValueDataBloc(event.value, canEmitAgain: true);
  }

  Stream<DataBlocEmission<TFailure, TValue>> onMapReplacedEvent(
      ReplacedSyncEvent<TValue> event) async* {
    yield ReplaceValueDataBloc(event.previousValue, event.currentValue, canEmitAgain: true);
  }

  Stream<DataBlocEmission<TFailure, TValue>> onMapDeletedEvent(DeletedSyncEvent<TValue> event);
}

class SingleValueBlocSyncer<TFailure, TValue> extends DataBlocSyncer<TFailure, TValue> {
  const SingleValueBlocSyncer({
    DataBlocSyncerActions actions = const DataBlocSyncerActions(),
  }) : super(actions: actions);

  @override
  Stream<DataBlocEmission<TFailure, TValue>> onMapCreatedEvent(
      CreatedSyncEvent<TValue> event) async* {
    yield EmitValueDataBloc(event.value);
  }

  @override
  Stream<DataBlocEmission<TFailure, TValue>> onMapDeletedEvent(
      DeletedSyncEvent<TValue> event) async* {
    yield EmitValueDataBloc(null);
  }
}

class MultiValueBlocSyncer<TFailure, TValue> extends DataBlocSyncer<TFailure, TValue> {
  const MultiValueBlocSyncer({
    DataBlocSyncerActions actions = const DataBlocSyncerActions(),
  }) : super(actions: actions);

  @override
  Stream<DataBlocEmission<TFailure, TValue>> onMapCreatedEvent(
      CreatedSyncEvent<TValue> event) async* {}

  @override
  Stream<DataBlocEmission<TFailure, TValue>> onMapDeletedEvent(
      DeletedSyncEvent<TValue> event) async* {}
}

class ListBlocSyncer<TFailure, TValue> extends DataBlocSyncer<TFailure, TValue> {
  const ListBlocSyncer({
    DataBlocSyncerActions actions = const DataBlocSyncerActions(),
  }) : super(actions: actions);

  @override
  Stream<DataBlocEmission<TFailure, TValue>> onMapCreatedEvent(
      CreatedSyncEvent<TValue> event) async* {
    yield AddValueDataBloc(event.value, canEmitAgain: true);
  }

  @override
  Stream<DataBlocEmission<TFailure, TValue>> onMapDeletedEvent(
      DeletedSyncEvent<TValue> event) async* {
    yield RemoveValueDataBloc(event.value, canEmitAgain: true);
  }
}
