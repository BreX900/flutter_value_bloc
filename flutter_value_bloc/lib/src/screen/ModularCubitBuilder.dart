import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/load/CircularProgressCubitBuilder.dart';
import 'package:flutter_value_bloc/src/view/ViewData.dart';
import 'package:value_bloc/value_bloc.dart';

class ModularCubitConsumer<C extends ModularCubitMixin<S>, S> extends StatelessWidget {
  final C modularCubit;

  /// [CircularProgressCubitBuilder.hasScaffold]
  final bool hasScaffold;
  final ViewErrorBuilder errorBuilder;
  final ViewLoaderBuilder loadingBuilder;
  final BlocWidgetListener<S> listener;
  final BlocWidgetBuilder<S> builder;

  const ModularCubitConsumer({
    Key key,
    this.modularCubit,
    this.hasScaffold = true,
    this.errorBuilder,
    this.loadingBuilder,
    this.listener,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modularCubit = this.modularCubit ?? BlocProvider.of<C>(context);

    Widget _build() {
      return BlocConsumer<C, S>(
        cubit: modularCubit,
        listener: listener ?? (context, state) => {},
        builder: builder,
      );
    }

    if (modularCubit is CubitLoadable<Object, S>) {
      return CircularProgressCubitBuilder(
        loadCubit: modularCubit.loadCubit,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        builder: (context) => _build(),
      );
    } else {
      return _build();
    }
  }
}
