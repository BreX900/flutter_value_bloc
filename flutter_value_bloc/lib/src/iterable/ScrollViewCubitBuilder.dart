import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:flutter_value_bloc/src/cubit_views/ValueViewBuilder.dart';
import 'package:flutter_value_bloc/src/utils.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class ScrollViewCubitBuilderBase<Value> extends StatelessWidget {
  final IterableCubit<Value, Object> iterableCubit;

  /// [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// [ScrollView.reverse]
  final bool reverse;

  /// [ScrollView.controller]
  final ScrollController controller;

  /// [ScrollView.primary]
  final bool primary;

  /// [ScrollView.physics]
  final ScrollPhysics physics;

  /// [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  /// [BoxScrollView.padding]
  final EdgeInsetsGeometry padding;

  final bool useOldValues;

  /// [CubitViewBuilder.loadingBuilder]
  final LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
      loadingBuilder;

  /// [CubitViewBuilder.errorBuilder]
  final ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
      errorBuilder;

  /// [CubitViewBuilder.emptyBuilder]
  final EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
      emptyBuilder;

  /// [ListView.itemBuilder]
  final ViewWidgetBuilder<Value> builder;

  const ScrollViewCubitBuilderBase({
    Key key,
    @required this.iterableCubit,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.useOldValues = false,
    this.loadingBuilder = CubitViewBuilder.buildLoading,
    this.errorBuilder = CubitViewBuilder.buildError,
    this.emptyBuilder = CubitViewBuilder.buildEmpty,
    @required this.builder,
  })  : assert(iterableCubit != null),
        assert(useOldValues != null),
        assert(builder != null),
        super(key: key);

  Widget buildDecoration(BuildContext context, Widget child) => child;

  Widget buildScrollView(BuildContext context, BuiltList<Value> values);

  @override
  Widget build(BuildContext context) {
    final current = BlocBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>(
      cubit: iterableCubit,
      builder: (context, state) {
        if (state is IterableCubitUpdating<Value, Object>) {
          if ((!useOldValues || state.oldAllValues.isEmpty) && loadingBuilder != null) {
            return loadingBuilder(context, iterableCubit, state);
          }
        } else if (state is IterableCubitUpdateFailed<Value, Object>) {
          if (errorBuilder != null) {
            return errorBuilder(context, iterableCubit, state);
          }
        } else if (state.values.isEmpty) {
          if (emptyBuilder != null) {
            return emptyBuilder(context, iterableCubit, state);
          }
        }

        final values = useOldValues && state is IterableCubitUpdating<Value, Object>
            ? state.oldValues
            : state.values;

        return buildScrollView(context, values);
      },
    );
    return buildDecoration(context, current);
  }
}
