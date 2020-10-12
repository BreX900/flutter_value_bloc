import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

import 'NameSingleCubit.dart';

class SingleNameScreen extends StatelessWidget {
  const SingleNameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SingleNameCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ViewValueCubitBuilder<SingleNameCubit,
              SingleValueState<String, Object>>.refresher(
            builder: (context, state) {
              return Text('${state.value}');
            },
          ),
        ),
      ),
    );
  }
}
