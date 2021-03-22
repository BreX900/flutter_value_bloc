import 'package:flutter/material.dart';

/// It build a widget for showing a progress
/// Ex. Center(child: CircularProgressIndicator(value: progress))
typedef LoadingViewBuilder = Widget Function(BuildContext context, double progress);

/// It build a widget for showing a error
/// Ex. Center(child: Text('$error'))
typedef ErrorViewBuilder = Widget Function(BuildContext context, Object error);

/// It build a widget for showing a empty list or empty screen
/// Center(child: Text('Empty'))
typedef EmptyViewBuilder = Widget Function(BuildContext context);

/// It defines default [ErrorViewBuilder], [LoadingViewBuilder], [EmptyViewBuilder]
class Views {
  final ErrorViewBuilder errorBuilder;
  final LoadingViewBuilder loadingBuilder;
  final EmptyViewBuilder emptyBuilder;

  const Views({
    this.errorBuilder = _buildError,
    this.loadingBuilder = _buildLoading,
    this.emptyBuilder = _buildEmpty,
  });

  const Views.raw({
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

  Views copyWith({
    LoadingViewBuilder loadingBuilder,
    ErrorViewBuilder errorBuilder,
    EmptyViewBuilder emptyBuilder,
  }) {
    return Views.raw(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }
}
