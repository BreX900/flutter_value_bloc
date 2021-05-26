import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class ActionDataCubitBuilder<
    TDataCubit extends DataCubit<DataState<TFailure, TData>, TFailure, TData>,
    TFailure,
    TData> extends StatelessWidget {
  final TDataCubit? dataCubit;

  final bool Function(DataState<TFailure, TData> state)? actuateWhen;

  final void Function(
    BuildContext context,
    DataState<TFailure, TData> state,
  ) actuator;

  final Widget Function(
    BuildContext context,
    DataState<TFailure, TData> state,
    VoidCallback? actuator,
  ) builder;

  const ActionDataCubitBuilder({
    Key? key,
    this.dataCubit,
    this.actuateWhen,
    required this.actuator,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataCubit = this.dataCubit ?? context.read<TDataCubit>();
    final actuateWhen = this.actuateWhen ?? (state) => state.status.canProcess;

    return BlocBuilder<TDataCubit, DataState<TFailure, TData>>(
      bloc: dataCubit,
      buildWhen: (p, c) => actuateWhen(p) != actuateWhen(c),
      builder: (context, state) {
        return builder(
          context,
          state,
          actuateWhen(state) ? () => actuator(context, state) : null,
        );
      },
    );
  }
}
