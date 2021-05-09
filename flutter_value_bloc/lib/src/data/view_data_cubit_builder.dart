import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/src/data/single_data_cubit_listener.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewDataCubitBuilder<
    TDataCubit extends SingleDataCubit<DataState<TFailure, TData>, TFailure, TData>,
    TFailure,
    TData> extends StatefulWidget {
  final TDataCubit singleDataCubit;
  final bool isPullDownEnabled;
  final BlocWidgetListener<DataState<TFailure, TData>>? listener;
  final BlocWidgetBuilder<DataState<TFailure, TData>> builder;

  const ViewDataCubitBuilder({
    Key? key,
    required this.singleDataCubit,
    this.isPullDownEnabled = false,
    this.listener,
    required this.builder,
  }) : super(key: key);

  @override
  _ViewDataCubitBuilderState<TDataCubit, TFailure, TData> createState() =>
      _ViewDataCubitBuilderState();
}

class _ViewDataCubitBuilderState<
    TDataCubit extends SingleDataCubit<DataState<TFailure, TData>, TFailure, TData>,
    TFailure,
    TData> extends State<ViewDataCubitBuilder<TDataCubit, TFailure, TData>> {
  RefreshController? _controller;

  @override
  void initState() {
    super.initState();
    _initCubit();
    _initController();
  }

  @override
  void didUpdateWidget(covariant ViewDataCubitBuilder<TDataCubit, TFailure, TData> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.singleDataCubit != oldWidget.singleDataCubit) {
      _initCubit();
    }
    if (widget.isPullDownEnabled != oldWidget.isPullDownEnabled) {
      _initController();
    }
  }

  void _initCubit() {
    if (widget.singleDataCubit.state.status.isIdle) {
      widget.singleDataCubit.read();
    }
  }

  void _initController() {
    if (widget.isPullDownEnabled) {
      _controller = RefreshController(
        initialRefreshStatus: _resolveRefresh(widget.singleDataCubit.state),
      );
    } else {
      _controller = null;
    }
  }

  RefreshStatus _resolveRefresh(DataState<TFailure, TData> state) {
    if (_controller!.headerStatus != RefreshStatus.refreshing) return _controller!.headerStatus;

    switch (state.status) {
      case DataStatus.reading:
        return RefreshStatus.refreshing;
      case DataStatus.readFailed:
        return RefreshStatus.failed;
      case DataStatus.read:
        return RefreshStatus.completed;
      default:
        return _controller!.headerStatus;
    }
  }

  void _refresh() {
    widget.singleDataCubit.read();
  }

  @override
  Widget build(BuildContext context) {
    Widget current = BlocBuilder<TDataCubit, DataState<TFailure, TData>>(
      bloc: widget.singleDataCubit,
      builder: widget.builder,
    );

    if (_controller != null) {
      current = SmartRefresher(
        controller: _controller!,
        enablePullDown: widget.isPullDownEnabled,
        onRefresh: _refresh,
        child: current,
      );
    }

    return DataCubitListener<TDataCubit, TFailure, TData>(
      dataCubit: widget.singleDataCubit,
      onIdle: (context, state) => widget.singleDataCubit.read(),
      child: current,
    );
  }
}
