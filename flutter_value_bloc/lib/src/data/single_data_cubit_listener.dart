import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class DataCubitListener<
    TDataCubit extends DataCubit<DataState<TFailure, TData>, TFailure, TData>,
    TFailure,
    TData> extends DataCubitListenerBase<TDataCubit, DataState<TFailure, TData>, TFailure, TData> {
  DataCubitListener({
    TDataCubit? dataCubit,
    BlocWidgetListener<DataState<TFailure, TData>>? onIdle,
    BlocWidgetListener<DataState<TFailure, TData>>? onWaiting,
    BlocWidgetListener<DataState<TFailure, TData>>? onCreating,
    BlocWidgetListener<DataState<TFailure, TData>>? onCreateFailed,
    BlocWidgetListener<DataState<TFailure, TData>>? onCreated,
    BlocWidgetListener<DataState<TFailure, TData>>? onReading,
    BlocWidgetListener<DataState<TFailure, TData>>? onReadFailed,
    BlocWidgetListener<DataState<TFailure, TData>>? onRead,
    BlocWidgetListener<DataState<TFailure, TData>>? onUpdating,
    BlocWidgetListener<DataState<TFailure, TData>>? onUpdateFailed,
    BlocWidgetListener<DataState<TFailure, TData>>? onUpdated,
    BlocWidgetListener<DataState<TFailure, TData>>? onDeleting,
    BlocWidgetListener<DataState<TFailure, TData>>? onDeleteFailed,
    BlocWidgetListener<DataState<TFailure, TData>>? onDeleted,
    BlocWidgetListener<DataState<TFailure, TData>>? listener,
    Widget? child,
  }) : super(
          dataCubit: dataCubit,
          onIdle: onIdle,
          onWaiting: onWaiting,
          onCreating: onCreating,
          onCreateFailed: onCreateFailed,
          onCreated: onCreated,
          onReading: onReading,
          onReadFailed: onReadFailed,
          onRead: onRead,
          onUpdating: onUpdating,
          onUpdateFailed: onUpdateFailed,
          onUpdated: onUpdated,
          onDeleting: onDeleting,
          onDeleteFailed: onDeleteFailed,
          onDeleted: onDeleted,
          listener: listener,
          child: child,
        );
}

class MultiDataCubitListener<
        TDataCubit extends DataCubit<MultiDataState<TFailure, TData>, TFailure, BuiltList<TData>>,
        TFailure,
        TData>
    extends DataCubitListenerBase<TDataCubit, MultiDataState<TFailure, TData>, TFailure,
        BuiltList<TData>> {
  MultiDataCubitListener({
    TDataCubit? dataCubit,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onIdle,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onWaiting,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onCreating,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onCreateFailed,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onCreated,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onReading,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onReadFailed,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onRead,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onUpdating,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onUpdateFailed,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onUpdated,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onDeleting,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onDeleteFailed,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onDeleted,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? listener,
    Widget? child,
  }) : super(
          dataCubit: dataCubit,
          onIdle: onIdle,
          onWaiting: onWaiting,
          onCreating: onCreating,
          onCreateFailed: onCreateFailed,
          onCreated: onCreated,
          onReading: onReading,
          onReadFailed: onReadFailed,
          onRead: onRead,
          onUpdating: onUpdating,
          onUpdateFailed: onUpdateFailed,
          onUpdated: onUpdated,
          onDeleting: onDeleting,
          onDeleteFailed: onDeleteFailed,
          onDeleted: onDeleted,
          listener: listener,
          child: child,
        );
}

class DataCubitListenerBase<
    TDataCubit extends DataCubit<TState, TFailure, TData>,
    TState extends DataState<TFailure, TData>,
    TFailure,
    TData> extends BlocListenerBase<TDataCubit, TState> {
  DataCubitListenerBase({
    Key? key,
    TDataCubit? dataCubit,
    BlocWidgetListener<TState>? onIdle,
    BlocWidgetListener<TState>? onWaiting,
    BlocWidgetListener<TState>? onCreating,
    BlocWidgetListener<TState>? onCreateFailed,
    BlocWidgetListener<TState>? onCreated,
    BlocWidgetListener<TState>? onReading,
    BlocWidgetListener<TState>? onReadFailed,
    BlocWidgetListener<TState>? onRead,
    BlocWidgetListener<TState>? onUpdating,
    BlocWidgetListener<TState>? onUpdateFailed,
    BlocWidgetListener<TState>? onUpdated,
    BlocWidgetListener<TState>? onDeleting,
    BlocWidgetListener<TState>? onDeleteFailed,
    BlocWidgetListener<TState>? onDeleted,
    BlocWidgetListener<TState>? listener,
    Widget? child,
  }) : super(
          key: key,
          bloc: dataCubit,
          listener: (context, state) {
            switch (state.status) {
              case DataStatus.idle:
                onIdle?.call(context, state);
                break;
              case DataStatus.waiting:
                onWaiting?.call(context, state);
                break;
              case DataStatus.creating:
                onCreating?.call(context, state);
                break;
              case DataStatus.createFailed:
                onCreateFailed?.call(context, state);
                break;
              case DataStatus.created:
                onCreated?.call(context, state);
                break;
              case DataStatus.reading:
                onReading?.call(context, state);
                break;
              case DataStatus.readFailed:
                onReadFailed?.call(context, state);
                break;
              case DataStatus.read:
                onRead?.call(context, state);
                break;
              case DataStatus.updating:
                onUpdating?.call(context, state);
                break;
              case DataStatus.updateFailed:
                onUpdateFailed?.call(context, state);
                break;
              case DataStatus.updated:
                onUpdated?.call(context, state);
                break;
              case DataStatus.deleting:
                onDeleting?.call(context, state);
                break;
              case DataStatus.deleteFailed:
                onDeleteFailed?.call(context, state);
                break;
              case DataStatus.deleted:
                onDeleted?.call(context, state);
                break;
            }
            listener?.call(context, state);
          },
          child: child,
        );
}
