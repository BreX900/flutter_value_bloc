import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class CircularProgressCubitBuilder extends StatelessWidget {
  final LoadCubit loadCubit;

  @visibleForTesting
  final ViewErrorBuilder errorBuilder;

  @visibleForTesting
  final ViewLoaderBuilder loadingBuilder;

  final WidgetBuilder builder;

  const CircularProgressCubitBuilder({
    Key key,
    @required this.loadCubit,
    this.errorBuilder,
    this.loadingBuilder,
    @required this.builder,
  }) : super(key: key);

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
          return view.loadingBuilder(context, state.progress);
        } else if (state is LoadCubitFailed) {
          return view.errorBuilder(context, state.failure);
        }

        return builder(context);
      },
    );
  }
}
