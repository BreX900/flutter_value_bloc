import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/action_data_bloc_builder.dart';
import 'package:value_bloc/value_bloc.dart';

class RefreshIconButton<TBloc extends DataBloc<Object, dynamic, DataBlocState<dynamic, Object>>>
    extends StatelessWidget {
  const RefreshIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionDataBlocBuilder<TBloc, Object, dynamic>(
      builder: (context, state, canPerform) => IconButton(
        onPressed: canPerform ? () => context.read<TBloc>().read(canForce: true) : null,
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
