import 'package:flutter/material.dart';

/// It build a widget for showing a progress
/// Ex. Center(child: CircularProgressIndicator(value: progress))
typedef ViewLoaderBuilder = Widget Function(BuildContext context, double progress);

/// It build a widget for showing a error
/// Ex. Center(child: Text('$error'))
typedef ViewErrorBuilder = Widget Function(BuildContext context, Object error);

/// It build a widget for showing a empty list or empty screen
/// Center(child: Text('Empty'))
typedef ViewEmptyBuilder = Widget Function(BuildContext context);

/// It defines default [ViewErrorBuilder], [ViewLoaderBuilder], [ViewEmptyBuilder]
class ViewData {
  final ViewErrorBuilder errorBuilder;
  final ViewLoaderBuilder loadingBuilder;
  final ViewEmptyBuilder emptyBuilder;

  const ViewData({
    this.errorBuilder = _buildError,
    this.loadingBuilder = _buildLoading,
    this.emptyBuilder = _buildEmpty,
  });

  const ViewData.raw({
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  static Widget _buildError(BuildContext context, Object error) {
    return Center(child: Text('$error'));
  }

  static Widget _buildLoading(BuildContext context, double progress) {
    return Center(
      child: CircularProgressIndicator(value: progress == 0.0 ? null : progress),
    );
  }

  static Widget _buildEmpty(BuildContext context) {
    return Center(child: Text('Empty'));
  }

  ViewData copyWith({
    ViewLoaderBuilder loadingBuilder,
    ViewErrorBuilder errorBuilder,
    ViewEmptyBuilder emptyBuilder,
  }) {
    return ViewData.raw(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }
}
