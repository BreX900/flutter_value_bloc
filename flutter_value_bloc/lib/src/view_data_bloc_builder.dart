import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/failure_data_bloc_notifier.dart';
import 'package:flutter_value_bloc/src/views/view_provider.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewDataBlocBuilder<TBloc extends DataBloc<TFailure, TValue, DataBlocState<TValue, TFailure>>,
    TFailure extends Object, TValue> extends StatelessWidget {
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

  Widget _buildView(BuildContext context, DataBlocState<TValue, TFailure> state) {
    if (state.hasData) {
      return builder(context, state.data);
    } else if (state.hasFailure) {
      if (failureBuilder != null) {
        return failureBuilder!(context, state.failure!);
      }
      return ViewsProvider.from<TFailure>(context).failureBuilder(context, state.failure!);
    } else {
      return ViewsProvider.from<TFailure>(context).loadingBuilder(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = singleDataBloc ?? BlocProvider.of<TBloc>(context);

    Widget current = DataBlocBuilder<TBloc, TFailure, TValue>(
      singleDataBloc: bloc,
      builder: _buildView,
    );

    if (canNotifyFailure) {
      current = FailureDataBlocNotifier<TBloc, TFailure>(
        dataBloc: bloc,
        listener: failureListener,
        child: current,
      );
    }

    return current;
  }
}

class DataBlocBuilder<TBloc extends DataBloc<TFailure, TValue, DataBlocState<TValue, TFailure>>,
    TFailure extends Object, TValue> extends StatefulWidget {
  final TBloc? singleDataBloc;
  final BlocWidgetBuilder<DataBlocState<TValue, TFailure>> builder;

  const DataBlocBuilder({
    Key? key,
    this.singleDataBloc,
    required this.builder,
  }) : super(key: key);

  @override
  State<DataBlocBuilder<TBloc, TFailure, TValue>> createState() => _DataBlocBuilderState();
}

class _DataBlocBuilderState<
    TBloc extends DataBloc<TFailure, TValue, DataBlocState<TValue, TFailure>>,
    TFailure extends Object,
    TValue> extends State<DataBlocBuilder<TBloc, TFailure, TValue>> {
  late TBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.singleDataBloc ?? BlocProvider.of<TBloc>(context);
    _initializeBloc(context, _bloc.state);
  }

  bool _checkBlocIsInitialized(
    DataBlocState<TValue, TFailure> prev,
    DataBlocState<TValue, TFailure> curr,
  ) {
    return prev.canInitialize != curr.canInitialize;
  }

  void _initializeBloc(BuildContext context, DataBlocState<TValue, TFailure> state) {
    if (state.canInitialize) {
      _bloc.read();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TBloc, DataBlocState<TValue, TFailure>>(
      bloc: _bloc,
      listenWhen: _checkBlocIsInitialized,
      listener: _initializeBloc,
      builder: widget.builder,
    );
  }
}
