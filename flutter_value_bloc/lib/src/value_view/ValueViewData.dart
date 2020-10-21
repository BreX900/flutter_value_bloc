import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

/// It build a widget for showing a progress
/// Ex. Center(child: CircularProgressIndicator(value: progress))
typedef ValueViewLoaderBuilder = Widget Function(BuildContext context, double progress);

/// It build a widget for showing a error
/// Ex. Center(child: Text('$error'))
typedef ValueViewErrorBuilder = Widget Function(BuildContext context, Object error);

/// It build a widget for showing a empty list or empty screen
/// Center(child: Text('Empty'))
typedef ValueViewEmptyBuilder = Widget Function(BuildContext context);

/// It defines default [ViewErrorBuilder], [ViewLoaderBuilder], [ViewEmptyBuilder]
class ValueViewData {
  final BlocWidgetBuilder<FailedValueState> errorBuilder;
  final BlocWidgetBuilder<ValueState> loadingBuilder;
  final BlocWidgetBuilder<ValueState> emptyBuilder;

  factory ValueViewData.fromViewData({
    @required ViewData viewData,
    BlocWidgetBuilder<FailedValueState> errorBuilder,
    BlocWidgetBuilder<ProcessingValueState> loadingBuilder,
    BlocWidgetBuilder<ValueState> emptyBuilder,
  }) {
    return ValueViewData(
      errorBuilder: errorBuilder ??
          (context, state) {
            return viewData.errorBuilder(context, state.error);
          },
      loadingBuilder: loadingBuilder ??
          (context, state) {
            return viewData.loadingBuilder(
                context, state is ProcessingValueState ? state.progress : null);
          },
      emptyBuilder: emptyBuilder ??
          (context, state) {
            return viewData.emptyBuilder(context);
          },
    );
  }

  const ValueViewData({
    @required this.errorBuilder,
    @required this.loadingBuilder,
    @required this.emptyBuilder,
  });

  ValueViewData copyWith({
    BlocWidgetBuilder<FailedValueState> errorBuilder,
    BlocWidgetBuilder<ProcessingValueState> loadingBuilder,
    BlocWidgetBuilder<ValueState> emptyBuilder,
  }) {
    return new ValueViewData(
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }
}
