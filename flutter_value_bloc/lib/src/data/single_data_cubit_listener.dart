import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class DataCubitListener<
    TDataCubit extends DataCubit<DataState<TFailure, TData>, TFailure, TData>,
    TFailure,
    TData> extends DataCubitListenerBase<TDataCubit, DataState<TFailure, TData>, TFailure, TData> {
  DataCubitListener({
    required TDataCubit dataCubit,
    BlocWidgetListener<DataState<TFailure, TData>>? onIdle,
    BlocWidgetListener<DataState<TFailure, TData>>? listener,
    Widget? child,
  }) : super(
          dataCubit: dataCubit,
          onIdle: onIdle,
          listener: listener,
        );
}

class MultiDataCubitListener<
        TDataCubit extends DataCubit<MultiDataState<TFailure, TData>, TFailure, BuiltList<TData>>,
        TFailure,
        TData>
    extends DataCubitListenerBase<TDataCubit, MultiDataState<TFailure, TData>, TFailure,
        BuiltList<TData>> {
  MultiDataCubitListener({
    required TDataCubit dataCubit,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? onIdle,
    BlocWidgetListener<MultiDataState<TFailure, TData>>? listener,
    Widget? child,
  }) : super(
          dataCubit: dataCubit,
          onIdle: onIdle,
          listener: listener,
        );
}

class DataCubitListenerBase<TDataCubit extends DataCubit<TState, TFailure, TData>,
    TState extends DataState<TFailure, TData>, TFailure, TData> extends StatelessWidget {
  final TDataCubit dataCubit;
  final BlocWidgetListener<TState>? onIdle;
  final BlocWidgetListener<TState>? listener;
  final Widget? child;

  const DataCubitListenerBase({
    Key? key,
    required this.dataCubit,
    this.onIdle,
    this.listener,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<TDataCubit, TState>(
      bloc: dataCubit,
      listener: (context, state) {
        switch (state.status) {
          case DataStatus.idle:
            onIdle?.call(context, state);
            break;
          case DataStatus.waiting:
            // TODO: Handle this case.
            break;
          case DataStatus.creating:
            // TODO: Handle this case.
            break;
          case DataStatus.createFailed:
            // TODO: Handle this case.
            break;
          case DataStatus.created:
            // TODO: Handle this case.
            break;
          case DataStatus.reading:
            // TODO: Handle this case.
            break;
          case DataStatus.readFailed:
            // TODO: Handle this case.
            break;
          case DataStatus.read:
            // TODO: Handle this case.
            break;
          case DataStatus.updating:
            // TODO: Handle this case.
            break;
          case DataStatus.updateFailed:
            // TODO: Handle this case.
            break;
          case DataStatus.updated:
            // TODO: Handle this case.
            break;
          case DataStatus.deleting:
            // TODO: Handle this case.
            break;
          case DataStatus.deleteFailed:
            // TODO: Handle this case.
            break;
          case DataStatus.deleted:
            // TODO: Handle this case.
            break;
        }
        listener?.call(context, state);
      },
      child: child,
    );
  }
}
