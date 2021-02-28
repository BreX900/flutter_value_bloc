import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:flutter_value_bloc/src/cubit_views/ValueViewBuilder.dart';
import 'package:value_bloc/value_bloc.dart';

class LoadViewCubitBuilder extends StatelessWidget {
  final LoadCubit loadCubit;

  /// If it is null, automatic checks if it has a [Scaffold] widget.
  /// If it doesn't have the [Scaffold] it wraps itself in a [Material] widget.
  ///
  /// If it is true it wraps in a [Material] widget if it is false it does nothing
  final bool useMaterial;

  final LoadingCubitViewBuilder<LoadCubit<Object>, LoadCubitLoading<Object>> loadingBuilder;

  final ErrorCubitViewBuilder<LoadCubit<Object>, LoadCubitFailed<Object>> errorBuilder;

  final BlocWidgetBuilder<LoadCubitState> builder;

  const LoadViewCubitBuilder({
    Key key,
    @required this.loadCubit,
    this.useMaterial,
    this.errorBuilder = CubitViewBuilder.buildError,
    this.loadingBuilder = CubitViewBuilder.buildLoading,
    @required this.builder,
  }) : super(key: key);

  Widget _build(BuildContext context, Widget child) {
    final useMaterial = this.useMaterial ?? Scaffold.of(context, nullOk: true) != null;
    return useMaterial ? Material(child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadCubit, LoadCubitState>(
      cubit: loadCubit,
      builder: (context, state) {
        if (state is LoadCubitLoading) {
          return _build(
            context,
            loadingBuilder != null
                ? loadingBuilder(context, loadCubit, state)
                : builder(context, state),
          );
        } else if (state is LoadCubitFailed) {
          return _build(
            context,
            errorBuilder != null
                ? errorBuilder(context, loadCubit, state)
                : builder(context, state),
          );
        }

        return builder(context, state);
      },
    );
  }
}
