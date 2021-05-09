import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class DataCubitBuilders<TFailure> {
  Widget buildProgress(BuildContext context, DataState<TFailure, dynamic> state) {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildFailure(BuildContext context, DataState<TFailure, dynamic> state) {
    return Text('${state.failure}');
  }

  BlocWidgetBuilder<DS> toViewBuilder<DS extends DataState<TFailure, S>, S>({
    required BlocWidgetBuilder<DS> successBuilder,
  }) {
    return (context, state) {
      if (state.hasFailure) {
        return buildFailure(context, state);
      }
      if (!state.hasData) {
        return buildProgress(context, state);
      }
      return successBuilder(context, state);
    };
  }

  BlocWidgetBuilder<DS> toActionBuilder<DS extends DataState<TFailure, S>, S>({
    required Widget Function() builder,
  }) {
    return (context, state) {
      if (state.hasFailure) {
        return buildFailure(context, state);
      }
      if (!state.hasData) {
        return buildProgress(context, state);
      }
      return builder(context, state);
    };
  }
}
