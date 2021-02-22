import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/view/ViewData.dart';
import 'package:flutter_value_bloc/src/view/ViewProvider.dart';
import 'package:value_bloc/value_bloc.dart';

class CircularProgressCubitBuilder extends StatelessWidget {
  final LoadCubit loadCubit;

  /// When it is inner the [Scaffold] widget it not wrap the ui with [Material] widget
  final bool hasScaffold;

  @visibleForTesting
  final ViewErrorBuilder errorBuilder;

  @visibleForTesting
  final ViewLoaderBuilder loadingBuilder;

  final WidgetBuilder builder;

  const CircularProgressCubitBuilder({
    Key key,
    @required this.loadCubit,
    this.hasScaffold = true,
    this.errorBuilder,
    this.loadingBuilder,
    @required this.builder,
  }) : super(key: key);

  Widget _build(BuildContext context, Widget child) {
    return hasScaffold ? child : Material(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final view = ViewDataProvider.of(context).copyWith(
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
    );

    return BlocBuilder<LoadCubit, LoadCubitState>(
      cubit: loadCubit,
      builder: (context, state) {
        if (state is LoadCubitLoading) {
          return _build(context, view.loadingBuilder(context, state.progress));
        } else if (state is LoadCubitFailed) {
          return _build(context, view.errorBuilder(context, state.failure));
        }

        return builder(context);
      },
    );
  }
}
