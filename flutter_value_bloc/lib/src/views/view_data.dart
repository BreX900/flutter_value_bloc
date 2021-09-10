import 'package:flutter/material.dart';

typedef FailureViewListener<TFailure> = void Function(BuildContext context, TFailure failure);

/// It build a widget for showing a progress
/// Ex. Center(child: CircularProgressIndicator(value: progress))
typedef LoadingViewBuilder = Widget Function(BuildContext context, double? progress);

/// It build a widget for showing a error
/// Ex. Center(child: Text('$error'))
typedef FailureViewBuilder<TFailure> = Widget Function(BuildContext context, TFailure failure);

/// It build a widget for showing a empty list or empty screen
/// Center(child: Text('Empty'))
typedef EmptyViewBuilder = Widget Function(BuildContext context);

/// It defines default [FailureViewBuilder], [LoadingViewBuilder], [EmptyViewBuilder]
class Views<TFailure> {
  final FailureViewListener<TFailure> failureListener;
  final FailureViewBuilder<TFailure> failureBuilder;
  final LoadingViewBuilder loadingBuilder;
  final EmptyViewBuilder emptyBuilder;

  const Views({
    this.failureListener = _listenFailure,
    this.failureBuilder = _buildFailure,
    this.loadingBuilder = _buildLoading,
    this.emptyBuilder = _buildEmpty,
  });

  const Views.raw({
    required this.failureListener,
    required this.failureBuilder,
    required this.loadingBuilder,
    required this.emptyBuilder,
  });

  static void _listenFailure(BuildContext context, Object? error) {}

  static Widget _buildFailure(BuildContext context, Object? error) {
    return Center(child: Text('$error'));
  }

  static Widget _buildLoading(BuildContext context, double? progress) {
    return Center(
      child: CircularProgressIndicator(value: progress == 0.0 ? null : progress),
    );
  }

  static Widget _buildEmpty(BuildContext context) {
    return const Center(child: Text('Empty'));
  }

  Views<TFailure> copyWith({
    FailureViewListener<TFailure>? failureListener,
    LoadingViewBuilder? loadingBuilder,
    FailureViewBuilder<TFailure>? failureBuilder,
    EmptyViewBuilder? emptyBuilder,
  }) {
    return Views.raw(
      failureListener: failureListener ?? this.failureListener,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      failureBuilder: failureBuilder ?? this.failureBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }
}
