import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/src/_utils.dart';
import 'package:flutter_value_bloc/src/cubit_views/cubit_views.dart';
import 'package:flutter_value_bloc/src/cubit_views/value_view_builder.dart';
import 'package:flutter_value_bloc/src/iterable/iterable_cubit_builder.dart';
import 'package:flutter_value_bloc/src/widgets/smart_refresher_cubit_builder.dart';
import 'package:value_bloc/value_bloc.dart';

class ScrollViewCubitBuilder<Value extends Object> extends ScrollViewCubitBuilderBase<Value> {
  final Widget Function(
    BuildContext context,
    IterableCubitState<Value, Object> state,
    BuiltList<Value> values,
  ) builder;

  const ScrollViewCubitBuilder({
    Key? key,
    required MultiCubit<Value, Object, Object> iterableCubit,
    bool useOldValues = true,
    int skipValuesCount = 0,
    int? takeValuesCount,
    int? valuesPerScroll,
    bool isEnabledPullDown = true,
    bool isEnabledPullUp = false,
    LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        loadingBuilder = CubitViewBuilder.buildLoading,
    ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        errorBuilder = CubitViewBuilder.buildError,
    EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        emptyBuilder = CubitViewBuilder.buildEmpty,
    required this.builder,
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
    return builder(context, state, values);
  }
}

abstract class ScrollViewCubitBuilderBase<Value extends Object>
    extends IterableCubitBuilderBase<Value> {
  final int? valuesPerScroll;
  final bool isEnabledPullDown;
  final bool isEnabledPullUp;

  const ScrollViewCubitBuilderBase({
    Key? key,
    required MultiCubit<Value, Object, Object> iterableCubit,
    bool useOldValues = true,
    int skipValuesCount = 0,
    int? takeValuesCount,
    this.valuesPerScroll,
    this.isEnabledPullDown = false,
    this.isEnabledPullUp = false,
    LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        loadingBuilder = CubitViewBuilder.buildLoading,
    ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        errorBuilder = CubitViewBuilder.buildError,
    EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
        emptyBuilder = CubitViewBuilder.buildEmpty,
  }) : super(
          key: key,
          iterableCubit: iterableCubit,
          skipValuesCount: skipValuesCount,
          takeValuesCount: takeValuesCount,
          useOldValues: useOldValues,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          emptyBuilder: emptyBuilder,
        );

  int get effectiveValuesPerScroll {
    final valuesPerScroll =
        this.valuesPerScroll ?? SmartRefresherCubitBuilder.defaultValuesPerScroll;
    if (takeValuesCount != null) min(valuesPerScroll, takeValuesCount!);
    return valuesPerScroll;
  }

  @override
  Widget buildDecoration(BuildContext context, Widget child) {
    final multiCubit = iterableCubit;
    if (multiCubit is MultiCubit<Value, Object, Object>) {
      return ViewCubitInitializer<MultiCubit<Value, Object, Object>,
          IterableCubitState<Value, Object>>(
        cubit: multiCubit,
        initializeWhen: (state) => state is IterableCubitUpdating<Value, Object>,
        initializer: (context, c) => c.fetch(
          section: PageOffset(skipValuesCount, effectiveValuesPerScroll),
        ),
        child: super.buildDecoration(context, child),
      );
    }
    return super.buildDecoration(context, child);
  }

  @override
  Widget buildValues(
    BuildContext context,
    IterableCubitState<Value, Object> state,
    BuiltList<Value> values,
  ) {
    final multiCubit = iterableCubit;
    if (multiCubit is MultiCubit<Value, Object, Object> && isEnabledPullDown && isEnabledPullUp) {
      return SmartRefresherCubitBuilder.multi(
        multiCubit: multiCubit,
        firstOffsetScroll: skipValuesCount,
        valuesPerScroll: effectiveValuesPerScroll,
        isEnabledPullDown: isEnabledPullDown,
        isEnabledPullUp: isEnabledPullUp,
        child: buildScrollView(context, state, values),
      );
    }
    return buildScrollView(context, state, values);
  }

  Widget buildScrollView(
    BuildContext context,
    IterableCubitState<Value, Object> state,
    BuiltList<Value> values,
  );
}
