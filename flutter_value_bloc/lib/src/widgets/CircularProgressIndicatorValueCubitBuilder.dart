import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

typedef _IndicatorBuilder = Widget Function(BuildContext context, double progress);

class ProgressIndicatorValueCubitBuilder extends StatelessWidget {
  final _IndicatorBuilder builder;

  const ProgressIndicatorValueCubitBuilder({
    Key key,
    @required this.builder,
  }) : super(key: key);

  const ProgressIndicatorValueCubitBuilder.circular({
    Key key,
    this.builder = _circularProgressIndicatorBuilder,
  }) : super(key: key);

  const ProgressIndicatorValueCubitBuilder.linear({
    Key key,
    this.builder = _linearProgressIndicatorBuilder,
  }) : super(key: key);

  static Widget _circularProgressIndicatorBuilder(BuildContext context, double progress) {
    return CircularProgressIndicator(value: progress == 0.0 ? null : progress);
  }

  static Widget _linearProgressIndicatorBuilder(BuildContext context, double progress) {
    return LinearProgressIndicator(value: progress == 0.0 ? null : progress);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValueCubit<ValueState<dynamic>, dynamic>, ValueState<dynamic>>(
      builder: (context, state) {
        if (state is ProcessingValueState<dynamic>) {
          return builder(context, state.progress);
        }
        return builder(context, 1.0);
      },
    );
  }
}
