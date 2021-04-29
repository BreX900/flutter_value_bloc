import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/views/ViewProvider.dart';
import 'package:value_bloc/value_bloc.dart';

/// It build a widget for showing a progress
/// Ex. Center(child: CircularProgressIndicator(value: progress))
typedef LoadingCubitViewBuilder<C extends Cubit, S> = Widget Function(
    BuildContext context, C cubit, S state);

/// It build a widget for showing a error
/// Ex. Center(child: Text('$error'))
typedef ErrorCubitViewBuilder<C extends Cubit, S> = Widget Function(
    BuildContext context, C cubit, S State);

/// It build a widget for showing a empty list or empty screen
/// Center(child: Text('Empty'))
typedef EmptyCubitViewBuilder<C extends Cubit, S> = Widget Function(
    BuildContext context, C cubit, S State);

/// It defines default [ErrorViewBuilder], [LoaderViewBuilder], [EmptyViewBuilder]
class CubitViews {
  final LoadingCubitViewBuilder<Cubit<Object>, Object> loadingBuilder;
  final ErrorCubitViewBuilder<Cubit<Object>, Object> errorBuilder;
  final EmptyCubitViewBuilder<Cubit<Object>, Object> emptyBuilder;

  const CubitViews({
    this.loadingBuilder = buildLoaderView,
    this.errorBuilder = buildErrorView,
    this.emptyBuilder = buildEmptyView,
  });

  const CubitViews.raw({
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.emptyBuilder,
  });

  CubitViews copyWith({
    LoadingCubitViewBuilder<Cubit<Object>, Object>? loadingBuilder,
    ErrorCubitViewBuilder<Cubit<Object>, Object>? errorBuilder,
    EmptyCubitViewBuilder<Cubit<Object>, Object>? emptyBuilder,
  }) {
    if ((errorBuilder == null || identical(errorBuilder, this.errorBuilder)) &&
        (loadingBuilder == null || identical(loadingBuilder, this.loadingBuilder)) &&
        (emptyBuilder == null || identical(emptyBuilder, this.emptyBuilder))) {
      return this;
    }

    return CubitViews(
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }

  static Widget buildLoaderView(BuildContext context, Cubit<Object> cubit, Object state) {
    final viewData = ViewsProvider.of(context);
    return viewData.loadingBuilder!(context, 0.0);
  }

  static Widget buildErrorView(BuildContext context, Cubit<Object> cubit, Object state) {
    final viewData = ViewsProvider.of(context);
    if (state is ObjectCubitUpdateFailed<Object, Object>) {
      return viewData.errorBuilder!(context, state.failure);
    } else if (state is IterableCubitUpdateFailed<Object, Object>) {
      return viewData.errorBuilder!(context, state.failure);
    } else {
      return viewData.errorBuilder!(context, null);
    }
  }

  static Widget buildEmptyView(BuildContext context, Cubit<Object> cubit, Object state) {
    final viewData = ViewsProvider.of(context);
    return viewData.emptyBuilder!(context);
  }
}
