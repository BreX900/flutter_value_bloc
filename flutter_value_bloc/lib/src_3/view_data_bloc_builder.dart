import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc_3.dart';

class ViewDataBlocBuilder<
    TBloc extends SingleDataBloc<TFailure, dynamic, TValue, SingleState<TFailure, TValue>>,
    TFailure,
    TValue> extends StatefulWidget {
  final TBloc? singleDataBloc;
  final Widget Function(BuildContext context, TFailure failure)? failureBuilder;
  final Widget Function(BuildContext context, TValue value) builder;

  const ViewDataBlocBuilder({
    Key? key,
    this.singleDataBloc,
    this.failureBuilder,
    required this.builder,
  }) : super(key: key);

  @override
  _ViewDataBlocBuilderState<TBloc, TFailure, TValue> createState() => _ViewDataBlocBuilderState();
}

class _ViewDataBlocBuilderState<
    TBloc extends SingleDataBloc<TFailure, dynamic, TValue, SingleState<TFailure, TValue>>,
    TFailure,
    TValue> extends State<ViewDataBlocBuilder<TBloc, TFailure, TValue>> {
  late TBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.singleDataBloc ?? BlocProvider.of(context);
    _initializeBloc(context, _bloc.state);
  }

  void _initializeBloc(BuildContext context, SingleState<TFailure, TValue> state) {
    if (state.canInitialize) {
      _bloc.read();
    }
    if (state.hasValue && state.hasFailure) {
      final views = ViewsProvider.maybeOf<TFailure>(context) ?? const Views();
      views.failureListener(context, state.failure);
    }
  }

  void _listenFailure(BuildContext context, SingleState<TFailure, TValue> state) {
    if (!(state.hasValue && state.hasFailure)) return;
    ViewsProvider.from<TFailure>(context).failureListener(context, state.failure);
  }

  Widget _buildView(BuildContext context, SingleState<TFailure, TValue> state) {
    if (state.hasValue) {
      return widget.builder(context, state.value);
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
    return BlocListener<TBloc, SingleState<TFailure, TValue>>(
      listenWhen: (prev, curr) => prev.hasFailure,
      listener: _listenFailure,
      child: BlocConsumer<TBloc, SingleState<TFailure, TValue>>(
        bloc: _bloc,
        listenWhen: (prev, curr) => prev.canInitialize != curr.canInitialize,
        listener: _initializeBloc,
        builder: _buildView,
      ),
    );
  }
}
