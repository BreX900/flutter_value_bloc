import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:flutter_value_bloc/src/cubit_views/ValueViewBuilder.dart';
import 'package:flutter_value_bloc/src/internalUtils.dart';
import 'package:flutter_value_bloc/src/iterable/ScrollViewCubitBuilder.dart';
import 'package:flutter_value_bloc/src/utils.dart';
import 'package:flutter_value_bloc/src/widgets/SmartRefresherCubitBuilder.dart';
import 'package:value_bloc/value_bloc.dart';

class GridViewCubitBuilder<Value> extends ScrollViewCubitBuilderBase<Value> {
  /// [GridView.gridDelegate]
  final SliverGridDelegate gridDelegate;

  const GridViewCubitBuilder({
    Key key,
    @required MultiCubit<Value, Object, Object> iterableCubit,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    bool useOldValues = false,
    this.gridDelegate,
    LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        loadingBuilder = CubitViewBuilder.buildLoading,
    ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        errorBuilder = CubitViewBuilder.buildError,
    EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        emptyBuilder = CubitViewBuilder.buildEmpty,
    @required ViewWidgetBuilder<Value> builder,
  }) : super(
          key: key,
          iterableCubit: iterableCubit,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          shrinkWrap: shrinkWrap,
          padding: padding,
          useOldValues: useOldValues,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          emptyBuilder: emptyBuilder,
          builder: builder,
        );

  @override
  Widget buildScrollView(BuildContext context, BuiltList<Value> values) {
    return GridView.custom(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: gridDelegate,
      childrenDelegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return builder(context, values[index]);
      }),
    );
  }
}

class SmartGridViewCubitBuilder<Value> extends GridViewCubitBuilder<Value> {
  final MultiCubit<Value, Object, Object> multiCubit;

  /// [SmartRefresherCubitBuilder.valuesPerScroll]
  final int valuesPerScroll;

  /// [SmartRefresherCubitBuilder.isEnabledPullDown]
  final bool isEnabledPullDown;

  /// [SmartRefresherCubitBuilder.isEnabledPullUp]
  final bool isEnabledPullUp;

  const SmartGridViewCubitBuilder({
    Key key,
    @required this.multiCubit,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    SliverGridDelegate gridDelegate,
    this.valuesPerScroll = 50,
    this.isEnabledPullDown = true,
    this.isEnabledPullUp = false,
    LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        loadingBuilder = CubitViewBuilder.buildLoading,
    ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        errorBuilder = CubitViewBuilder.buildError,
    EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        emptyBuilder = CubitViewBuilder.buildEmpty,
    @required ViewWidgetBuilder<Value> builder,
  }) : super(
          key: key,
          iterableCubit: multiCubit,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          shrinkWrap: shrinkWrap,
          padding: padding,
          gridDelegate: gridDelegate,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          emptyBuilder: emptyBuilder,
          builder: builder,
        );

  @override
  Widget buildDecoration(BuildContext context, Widget child) {
    return ViewCubitInitializer<MultiCubit<Value, Object, Object>>(
      cubit: multiCubit,
      initializer: (context, c) => c.fetch(section: IterableSection(0, valuesPerScroll)),
      child: super.buildDecoration(context, child),
    );
  }

  @override
  Widget buildScrollView(BuildContext context, BuiltList<Value> values) {
    return SmartRefresherCubitBuilder.multi(
      multiCubit: multiCubit,
      valuesPerScroll: valuesPerScroll,
      isEnabledPullDown: isEnabledPullDown,
      isEnabledPullUp: isEnabledPullUp,
      child: super.buildScrollView(context, values),
    );
  }
}
