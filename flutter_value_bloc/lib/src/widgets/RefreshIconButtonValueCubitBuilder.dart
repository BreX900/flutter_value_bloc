import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class RefreshIconButtonValueCubitBuilder<C extends ValueCubit<ValueState<dynamic>, dynamic>>
    extends StatelessWidget {
  final C valueCubit;
  final bool isLoading;
  final Widget icon;

  const RefreshIconButtonValueCubitBuilder({
    Key key,
    this.valueCubit,
    this.isLoading = false,
    this.icon = const Icon(Icons.refresh),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueCubit = this.valueCubit ?? context.read<C>();

    return BlocBuilder<C, ValueState<dynamic>>(
      cubit: valueCubit,
      builder: (context, state) {
        return IconButton(
          onPressed: state.canRefresh ? () => valueCubit.refresh(isLoading: isLoading) : null,
          icon: icon,
        );
      },
    );
  }
}
