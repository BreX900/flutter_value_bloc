import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/load/load_view_cubit_builder.dart';
import 'package:value_bloc/value_bloc.dart';

typedef _LoadModuleBuilder = Widget Function(BuildContext context, LoadCubit cubit);

class ModularViewCubitBuilder<C extends ModularCubitMixin<S>, S> extends StatelessWidget {
  final C? modularCubit;

  final _LoadModuleBuilder? loadModuleBuilder;

  final BlocBuilderCondition<S>? buildWhen;
  final BlocWidgetBuilder<S> builder;

  const ModularViewCubitBuilder({
    Key? key,
    this.modularCubit,
    this.loadModuleBuilder,
    this.buildWhen,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modularCubit = this.modularCubit ?? BlocProvider.of<C>(context);

    if (modularCubit is LoadCubitModule<Object, S>) {
      if (loadModuleBuilder != null) {
        return loadModuleBuilder!(context, modularCubit.loadCubit);
      } else {
        return LoadViewCubitBuilder(
          loadCubit: modularCubit.loadCubit,
          builder: (context, state) => _buildView(context, modularCubit),
        );
      }
    } else {
      return _buildView(context, modularCubit);
    }
  }

  Widget _buildView(BuildContext context, C modularCubit) {
    return BlocBuilder<C, S>(
      bloc: modularCubit,
      buildWhen: buildWhen,
      builder: builder,
    );
  }
}

class ModularViewCubitConsumer<C extends ModularCubitMixin<S>, S> extends StatelessWidget {
  final C? modularCubit;

  final _LoadModuleBuilder? loadModuleBuilder;

  final BlocBuilderCondition<S>? listenWhen;
  final BlocWidgetListener<S> listener;

  final BlocBuilderCondition<S>? buildWhen;
  final BlocWidgetBuilder<S> builder;

  const ModularViewCubitConsumer({
    Key? key,
    this.modularCubit,
    this.loadModuleBuilder,
    this.listenWhen,
    required this.listener,
    this.buildWhen,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modularCubit = this.modularCubit ?? BlocProvider.of<C>(context);

    return BlocListener<C, S>(
      bloc: modularCubit,
      listenWhen: listenWhen,
      listener: listener,
      child: ModularViewCubitBuilder(
        modularCubit: modularCubit,
        loadModuleBuilder: loadModuleBuilder,
        buildWhen: buildWhen,
        builder: builder,
      ),
    );
  }
}
