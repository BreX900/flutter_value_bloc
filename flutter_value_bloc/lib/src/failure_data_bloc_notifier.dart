import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/views/view_provider.dart';
import 'package:flutter_value_bloc/src/widgets.dart';
import 'package:provider/single_child_widget.dart';
import 'package:value_bloc/value_bloc.dart';

class FailureDataBlocNotifier<
    TBloc extends DataBloc<TFailure, dynamic, DataBlocState<TFailure, dynamic>>,
    TFailure> extends SingleChildStatelessWidget with _ListenFailure<TFailure> {
  final TBloc? dataBloc;

  /// It will call the failure handler even without having the data in the state
  @override
  final bool? shouldListenWithData;

  @override
  final void Function(BuildContext context, TFailure failure)? listener;

  const FailureDataBlocNotifier({
    Key? key,
    this.dataBloc,
    this.shouldListenWithData = true,
    this.listener,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocListener<TBloc, DataBlocState<TFailure, dynamic>>(
      bloc: dataBloc,
      listenWhen: _listenWhen,
      listener: _listenFailure,
      child: child,
    );
  }
}

class FailureGroupDataBlocNotifier<TFailure> extends SingleChildStatelessWidget
    with _ListenFailure<TFailure> {
  final List<DataBloc<TFailure, dynamic, DataBlocState<TFailure, dynamic>>> blocs;

  /// It will call the failure handler even without having the data in the state
  @override
  final bool? shouldListenWithData;

  @override
  final void Function(BuildContext context, TFailure failure)? listener;

  const FailureGroupDataBlocNotifier({
    Key? key,
    required this.blocs,
    this.shouldListenWithData = true,
    this.listener,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocGroupListener(
      blocs: blocs,
      listenWhen: _listenWhen,
      listener: _listenFailure,
      child: child,
    );
  }
}

mixin _ListenFailure<TFailure> {
  bool? get shouldListenWithData;

  void Function(BuildContext context, TFailure failure)? get listener;

  bool _listenWhen(DataBlocState<TFailure, dynamic> prev, DataBlocState<TFailure, dynamic> curr) {
    return prev.failureOrNull != curr.failureOrNull;
  }

  void _listenFailure(BuildContext context, DataBlocState<TFailure, dynamic> state) {
    if (!state.hasFailure) return;

    if (shouldListenWithData == true && !state.hasData) return;
    if (shouldListenWithData == false && state.hasData) return;

    final listener = this.listener;
    if (listener != null) {
      listener(context, state.failure);
    } else {
      ViewsProvider.from<TFailure>(context).failureListener(context, state.failure);
    }
  }
}
