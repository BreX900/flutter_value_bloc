import 'package:flutter/material.dart';

typedef ViewLoaderBuilder = Widget Function(BuildContext context, double progress);
typedef ViewErrorBuilder = Widget Function(BuildContext context, Object error);
typedef ViewEmptyBuilder = Widget Function(BuildContext context);

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
    return new ViewData.raw(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }
}
