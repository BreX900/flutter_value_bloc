import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/cubits/_utils.dart';
import 'package:provider/single_child_widget.dart';
import 'package:value_bloc/value_bloc.dart';

class DataBlocListener<TBloc extends BlocBase<DataBlocState<dynamic, dynamic>>>
    extends SingleChildStatefulWidget with BlocOnSingleChildWidget<TBloc> {
  @override
  final TBloc? bloc;
  final BlocWidgetListener<DataBlocState<dynamic, dynamic>>? onUpdating;
  final BlocWidgetListener<DataBlocState<dynamic, dynamic>>? onUpdated;
  final BlocWidgetListener<DataBlocState<dynamic, dynamic>>? onIdle;

  DataBlocListener({
    Key? key,
    this.bloc,
    this.onUpdating,
    this.onUpdated,
    required this.onIdle,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  State<DataBlocListener<TBloc>> createState() => _DataBlocListenerState();
}

class _DataBlocListenerState<TBloc extends BlocBase<DataBlocState<dynamic, dynamic>>>
    extends SingleChildState<DataBlocListener<TBloc>>
    with BlocOnSingleChildState<DataBlocListener<TBloc>, TBloc> {
  @override
  void initState() {
    super.initState();
    onBloc(bloc.state);
  }

  @override
  void onUpdateBloc(TBloc oldBloc) {
    onBloc(bloc.state);
  }

  void onBloc(DataBlocState<dynamic, dynamic> state) {
    if (state.isIdle) {
      widget.onIdle?.call(context, state);
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocListener<TBloc, DataBlocState<dynamic, dynamic>>(
      bloc: bloc,
      listenWhen: (prev, curr) => prev.isIdle != curr.isIdle,
      listener: (context, state) => widget.onIdle?.call(context, state),
      child: super.buildWithChild(context, child),
    );
  }
}
