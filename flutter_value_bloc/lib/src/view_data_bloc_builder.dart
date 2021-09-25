import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/failure_data_bloc_notifier.dart';
import 'package:flutter_value_bloc/src/views/view_provider.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewDataBlocBuilder<TBloc extends DataBloc<TFailure, TValue, DataBlocState<TFailure, TValue>>,
    TFailure, TValue> extends StatefulWidget {
  final TBloc? singleDataBloc;
  final bool canNotifyFailure;
  final Widget Function(BuildContext context, TFailure failure)? failureListener;
  final Widget Function(BuildContext context, TFailure failure)? failureBuilder;
  final Widget Function(BuildContext context, TValue value) builder;

  const ViewDataBlocBuilder({
    Key? key,
    this.singleDataBloc,
    this.canNotifyFailure = false,
    this.failureListener,
    this.failureBuilder,
    required this.builder,
  }) : super(key: key);

  @override
  _ViewDataBlocBuilderState<TBloc, TFailure, TValue> createState() => _ViewDataBlocBuilderState();
}

class _ViewDataBlocBuilderState<
    TBloc extends DataBloc<TFailure, TValue, DataBlocState<TFailure, TValue>>,
    TFailure,
    TValue> extends State<ViewDataBlocBuilder<TBloc, TFailure, TValue>> {
  late TBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.singleDataBloc ?? BlocProvider.of(context);
    _initializeBloc(context, _bloc.state);
  }

  bool _checkBlocIsInitialized(
    DataBlocState<TFailure, TValue> prev,
    DataBlocState<TFailure, TValue> curr,
  ) {
    return prev.canInitialize != curr.canInitialize;
  }

  void _initializeBloc(BuildContext context, DataBlocState<TFailure, TValue> state) {
    if (state.canInitialize) {
      _bloc.read();
    }
  }

  Widget _buildView(BuildContext context, DataBlocState<TFailure, TValue> state) {
    if (state.hasData) {
      return widget.builder(context, state.data);
    } else if (state.hasFailure) {
      if (widget.failureBuilder != null) {
        return widget.failureBuilder!(context, state.failure);
      }
      return ViewsProvider.from<TFailure>(context).failureBuilder(context, state.failure);
    } else {
      return ViewsProvider.from<TFailure>(context).loadingBuilder(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget current = BlocConsumer<TBloc, DataBlocState<TFailure, TValue>>(
      bloc: _bloc,
      listenWhen: _checkBlocIsInitialized,
      listener: _initializeBloc,
      builder: _buildView,
    );
    if (widget.canNotifyFailure) {
      current = FailureDataBlocNotifier<TBloc, TFailure>(
        dataBloc: _bloc,
        listener: widget.failureListener,
        child: current,
      );
    }
    return current;
  }
}
