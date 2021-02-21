import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/load/CircularProgressCubitBuilder.dart';
import 'package:flutter_value_bloc/src/view/ViewData.dart';
import 'package:value_bloc/value_bloc.dart';

class ModularCubitConsumer<C extends CloseableCubit<S>, S> extends StatelessWidget {
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
    final screenCubit = this.modularCubit ?? BlocProvider.of<C>(context);

    Widget _build() {
      return BlocConsumer<C, S>(
        cubit: screenCubit,
        listener: listener ?? (context, state) => {},
        builder: builder,
      );
    }

    if (screenCubit is CubitLoadable<Object>) {
      final cubitLoadable = (screenCubit as CubitLoadable<Object>);
      return CircularProgressCubitBuilder(
        loadCubit: cubitLoadable.loadCubit,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        builder: (context) => _build(),
      );
    }
  }
}
