import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/src/utils.dart';
import 'package:value_bloc/value_bloc.dart';

class ValueViewCubitBuilder<Value> extends StatelessWidget {
  final ObjectCubit<Value, Object> objectCubit;
  final ObjectWidgetBuilder<Value> builder;

  const ValueViewCubitBuilder({
    Key key,
    @required this.objectCubit,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObjectCubit<Value, Object>, ObjectCubitState<Value, Object>>(
      cubit: objectCubit,
      builder: (context, state) {
        return builder(context, state.value);
      },
    );
  }
}
