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
    _readBloc(_bloc.state);
  }

  void _readBloc(SingleState<TFailure, TValue> state) {
    if (_bloc.state.hasValueOrFailure) return;
    _bloc.read();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TBloc, SingleState<TFailure, TValue>>(
      bloc: _bloc,
      listenWhen: (prev, curr) => prev.hasValueOrFailure != curr.hasValueOrFailure,
      listener: (context, state) => _readBloc(state),
      builder: (context, state) {
        if (state.hasValue) {
          return widget.builder(context, state.value);
        } else if (state.hasFailure) {
          if (widget.failureBuilder != null) {
            return widget.failureBuilder!(context, state.failure);
          }
          final views = ViewsProvider.maybeOf<TFailure>(context) ?? const Views();
          return views.failureBuilder(context, state.failure);
        } else {
          final views = ViewsProvider.maybeOf<TFailure>(context) ?? const Views();
          return views.loadingBuilder(context, null);
        }
      },
    );
  }
}
