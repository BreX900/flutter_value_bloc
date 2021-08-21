import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src_3/widgets.dart';
import 'package:value_bloc/value_bloc_3.dart';

class ActionDataBlocBuilder<
    TBloc extends DataBloc<TFailure, dynamic, TData, DataBlocState<TFailure, TData>>,
    TFailure,
    TData> extends StatelessWidget {
  final TBloc? dataBloc;
  final bool isDataAction;

  /// Pass state ???
  final Widget Function(BuildContext context, DataBlocState<TFailure, TData> state, bool canPerform)
      builder;

  const ActionDataBlocBuilder({
    Key? key,
    this.dataBloc,
    this.isDataAction = false,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TBloc, DataBlocState<TFailure, TData>>(
      bloc: dataBloc,
      buildWhen: (prev, curr) {
        return _canPerform(prev, isDataAction) != _canPerform(curr, isDataAction);
      },
      builder: (context, state) => builder(context, state, _canPerform(state, isDataAction)),
    );
  }
}

class ActionGroupDataBlocBuilder<TFailure, TData> extends StatelessWidget {
  final List<DataBloc<TFailure, dynamic, TData, DataBlocState<TFailure, TData>>> dataBlocs;
  final bool isDataAction;
  final Widget Function(BuildContext context, bool canPerform) builder;

  const ActionGroupDataBlocBuilder({
    Key? key,
    required this.dataBlocs,
    this.isDataAction = false,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocGroupSelector<DataBloc<TFailure, dynamic, TData, DataBlocState<TFailure, TData>>,
        DataBlocState<TFailure, TData>, bool>(
      blocs: dataBlocs,
      selector: (states) => states.every((state) => _canPerform(state, isDataAction)),
      builder: builder,
    );
  }
}

bool _canPerform(DataBlocState<dynamic, dynamic> state, bool isDataAction) {
  return isDataAction ? state.canPerformDataAction : state.canPerformAction;
}
