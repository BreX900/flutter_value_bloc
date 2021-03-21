import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:flutter_value_bloc/src/cubit_views/ValueViewBuilder.dart';
import 'package:flutter_value_bloc/src/iterable/ScrollViewCubitBuilder.dart';
import 'package:flutter_value_bloc/src/utils.dart';
import 'package:value_bloc/value_bloc.dart';

class ListViewCubitBuilder<Value> extends ScrollViewCubitBuilderBase<Value> {
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

  /// [ListView.separatorBuilder]
  final IndexedWidgetBuilder separatorBuilder;

  /// [ListView.itemBuilder]
  final CubitValueWidgetBuilder<Value> builder;

  const ListViewCubitBuilder({
    Key key,
    @required MultiCubit<Value, Object, Object> iterableCubit,
    bool useOldValues = true,
    int skipValuesCount = 0,
    int takeValuesCount,
    int valuesPerScroll,
    bool isEnabledPullDown = true,
    bool isEnabledPullUp = false,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        loadingBuilder = CubitViewBuilder.buildLoading,
    ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        errorBuilder = CubitViewBuilder.buildError,
    EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        emptyBuilder = CubitViewBuilder.buildEmpty,
    this.separatorBuilder,
    @required this.builder,
  }) : super(
          key: key,
          iterableCubit: iterableCubit,
          useOldValues: useOldValues,
          skipValuesCount: skipValuesCount,
          takeValuesCount: takeValuesCount,
          valuesPerScroll: valuesPerScroll,
          isEnabledPullDown: isEnabledPullDown,
          isEnabledPullUp: isEnabledPullUp,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          emptyBuilder: emptyBuilder,
        );

  @override
  Widget buildScrollView(
    BuildContext context,
    IterableCubitState<Value, Object> state,
    BuiltList<Value> values,
  ) {
    Widget itemBuilder(BuildContext context, int index) {
      return builder(context, values[index]);
    }

    if (separatorBuilder != null) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: values.length,
        separatorBuilder: separatorBuilder,
        itemBuilder: itemBuilder,
      );
    }
    return ListView.builder(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: values.length,
      itemBuilder: itemBuilder,
    );
  }
}
