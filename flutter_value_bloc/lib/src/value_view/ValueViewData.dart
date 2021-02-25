import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

/// It build a widget for showing a progress
/// Ex. Center(child: CircularProgressIndicator(value: progress))
typedef ValueViewLoaderBuilder<S> = Widget Function(BuildContext context, Cubit<S> cubit, S State);

/// It build a widget for showing a error
/// Ex. Center(child: Text('$error'))
typedef ValueViewErrorBuilder<S> = Widget Function(BuildContext context, Cubit<S> cubit, S State);

/// It build a widget for showing a empty list or empty screen
/// Center(child: Text('Empty'))
typedef ValueViewEmptyBuilder<S> = Widget Function(BuildContext context, Cubit<S> cubit, S State);

/// It defines default [ViewErrorBuilder], [ViewLoaderBuilder], [ViewEmptyBuilder]
class ValueViewData {
  final ValueViewErrorBuilder<Object> errorBuilder;
  final ValueViewLoaderBuilder<Object> loadingBuilder;
  final ValueViewEmptyBuilder<Object> emptyBuilder;

  const ValueViewData({
    this.errorBuilder = buildErrorView,
    this.loadingBuilder = buildLoaderView,
    this.emptyBuilder = buildEmptyView,
  });

  const ValueViewData.raw({
    @required this.errorBuilder,
    @required this.loadingBuilder,
    @required this.emptyBuilder,
  });

  ValueViewData copyWith({
    ValueViewErrorBuilder<Object> errorBuilder,
    ValueViewLoaderBuilder<Object> loadingBuilder,
    ValueViewEmptyBuilder<Object> emptyBuilder,
  }) {
    if ((errorBuilder == null || identical(errorBuilder, this.errorBuilder)) &&
        (loadingBuilder == null || identical(loadingBuilder, this.loadingBuilder)) &&
        (emptyBuilder == null || identical(emptyBuilder, this.emptyBuilder))) {
      return this;
    }

    return ValueViewData(
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }

  static Widget buildErrorView(BuildContext context, Cubit<Object> cubit, Object state) {
    final viewData = ViewDataProvider.of(context);
    return viewData.errorBuilder(context, null);
  }

  static Widget buildLoaderView(BuildContext context, Cubit<Object> cubit, Object state) {
    final viewData = ViewDataProvider.of(context);
    return viewData.loadingBuilder(context, 0.0);
  }

  static Widget buildEmptyView(BuildContext context, Cubit<Object> cubit, Object state) {
    final viewData = ViewDataProvider.of(context);
    return viewData.emptyBuilder(context);
  }
}
