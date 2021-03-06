import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/src/data/single_data_cubit_listener.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewDataCubitBuilder<
    TDataCubit extends SingleDataCubit<DataState<TFailure, TData>, TFailure, TData>,
    TFailure,
    TData> extends StatefulWidget {
  final TDataCubit? singleDataCubit;
  final bool? canShowFailure;
  final bool isPullDownEnabled;
  final BlocWidgetBuilder<DataState<TFailure, TData>>? progressBuilder;
  final BlocWidgetBuilder<DataState<TFailure, TData>>? failureBuilder;
  final BlocWidgetBuilder<DataState<TFailure, TData>> builder;

  const ViewDataCubitBuilder({
    Key? key,
    this.singleDataCubit,
    this.canShowFailure,
    this.isPullDownEnabled = false,
    this.progressBuilder,
    this.failureBuilder,
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
  late TDataCubit _cubit;
  RefreshController? _controller;

  @override
  void initState() {
    super.initState();
    _cubit = widget.singleDataCubit ?? context.read<TDataCubit>();
    _initCubit();
    _initController();
  }

  @override
  void didUpdateWidget(covariant ViewDataCubitBuilder<TDataCubit, TFailure, TData> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCubit = widget.singleDataCubit ?? context.read<TDataCubit>();
    final oldCubit = oldWidget.singleDataCubit ?? _cubit;
    if (newCubit != oldCubit) {
      _cubit = newCubit;
      _initCubit();
    }
    if (widget.isPullDownEnabled != oldWidget.isPullDownEnabled) {
      _initController();
    }
  }

  void _initCubit() {
    if (_cubit.state.status.isIdle) {
      _cubit.read();
    }
  }

  void _initController() {
    if (widget.isPullDownEnabled) {
      _controller = RefreshController(
        initialRefreshStatus: _resolveRefresh(_cubit.state),
      );
    } else {
      _controller = null;
    }
  }

  RefreshStatus _resolveRefresh(DataState<TFailure, TData> state) {
    if (_controller!.headerStatus != RefreshStatus.refreshing) return _controller!.headerStatus!;

    switch (state.status) {
      case DataStatus.reading:
        return RefreshStatus.refreshing;
      case DataStatus.readFailed:
        return RefreshStatus.failed;
      case DataStatus.read:
        return RefreshStatus.completed;
      default:
        return _controller!.headerStatus!;
    }
  }

  void _refresh() {
    _cubit.clean();
  }

  @override
  Widget build(BuildContext context) {
    final viewTheme = context.watch<ViewDataCubitTheme<TFailure>>();

    Widget current = BlocBuilder<TDataCubit, DataState<TFailure, TData>>(
      bloc: widget.singleDataCubit,
      builder: (context, state) {
        if (state.hasFailure && (widget.canShowFailure ?? viewTheme.canShowFailure)) {
          return widget.failureBuilder?.call(context, state) ??
              viewTheme.failureBuilder(context, _cubit, state);
        }
        if (state.notHasData) {
          return widget.progressBuilder?.call(context, state) ??
              viewTheme.progressBuilder(context, _cubit, state);
        }
        return widget.builder(context, state);
      },
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
      dataCubit: _cubit,
      onIdle: (context, state) => _cubit.read(),
      child: current,
    );
  }
}
