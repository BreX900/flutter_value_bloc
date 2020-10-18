import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

import 'NameSingleCubit.dart';

class SingleScreen extends StatelessWidget {
  const SingleScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SingleNameCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ViewSingleValueCubitBuilder<SingleNameCubit, String, Object>(
            plugin: RefresherValueCubitPlugin(),
            builder: (context, state) {
              return Text('${state.value}');
            },
          ),
        ),
      ),
    );
  }
}
