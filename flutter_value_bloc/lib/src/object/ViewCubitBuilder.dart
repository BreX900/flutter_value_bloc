import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:flutter_value_bloc/src/cubit_views/ValueViewBuilder.dart';
import 'package:flutter_value_bloc/src/internalUtils.dart';
import 'package:flutter_value_bloc/src/utils.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewCubitBuilder<Value> extends StatelessWidget {
  final ObjectCubit<Value, Object> objectCubit;

  /// [CubitViewBuilder.loadingBuilder]
  final LoadingCubitViewBuilder<ObjectCubit<Value, Object>, ObjectCubitState<Value, Object>>?
      loadingBuilder;

  /// [CubitViewBuilder.errorBuilder]
  final ErrorCubitViewBuilder<ObjectCubit<Value, Object>, ObjectCubitState<Value, Object>>?
      errorBuilder;

  /// [CubitViewBuilder.emptyBuilder]
  final EmptyCubitViewBuilder<ObjectCubit<Value, Object>, ObjectCubitState<Value, Object>>?
      emptyBuilder;

  final CubitValueWidgetBuilder<Value?> builder;

  const ViewCubitBuilder({
    Key? key,
    required this.objectCubit,
    this.loadingBuilder = CubitViewBuilder.buildLoading,
    this.errorBuilder = CubitViewBuilder.buildError,
    this.emptyBuilder = CubitViewBuilder.buildEmpty,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final objectCubit = this.objectCubit;

    final current = BlocBuilder<ObjectCubit<Value, Object>, ObjectCubitState<Value, Object>>(
      bloc: objectCubit,
      builder: (context, state) {
        if (state is ObjectCubitUpdating<Value, Object>) {
          if (loadingBuilder != null) {
            return loadingBuilder!(context, objectCubit, state);
          }
        } else if (state is ObjectCubitUpdateFailed<Value, Object>) {
          if (errorBuilder != null) {
            return errorBuilder!(context, objectCubit, state);
          }
        } else if (!state.hasValue!) {
          if (emptyBuilder != null) {
            return emptyBuilder!(context, objectCubit, state);
          }
        }

        return builder(context, state.value);
      },
    );

    if (objectCubit is SingleCubit<Value, Object, Object>) {
      return ViewCubitInitializer<SingleCubit<Value, Object, Object>,
          ObjectCubitState<Value, Object>>(
        cubit: objectCubit,
        initializeWhen: (state) => state is ObjectCubitUpdating<Value, Object>,
        initializer: (context, c) => c.fetch(),
        child: current,
      );
    }

    return current;
  }
}
