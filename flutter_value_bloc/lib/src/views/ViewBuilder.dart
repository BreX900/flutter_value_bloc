import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/views/ViewData.dart';
import 'package:flutter_value_bloc/src/views/ViewProvider.dart';

/// This is a view builder with default [ErrorViewBuilder],
/// [LoadingViewBuilder], [EmptyViewBuilder]
class ViewBuilder extends StatelessWidget {
  final double progress;
  final bool isEmpty;
  final Object error;
  final ErrorViewBuilder errorBuilder;
  final LoadingViewBuilder loadingBuilder;
  final EmptyViewBuilder emptyBuilder;
  final WidgetBuilder builder;

  const ViewBuilder({
    Key key,
    this.progress,
    this.isEmpty = false,
    this.error,
    this.errorBuilder = buildError,
    this.loadingBuilder = buildLoading,
    this.emptyBuilder = buildEmpty,
    @required this.builder,
  }) : super(key: key);

  static Widget buildError(BuildContext context, Object error) {
    return ViewsProvider.of(context).errorBuilder(context, error);
  }

  static Widget buildLoading(BuildContext context, double progress) {
    return ViewsProvider.of(context).loadingBuilder(context, progress);
  }

  static Widget buildEmpty(BuildContext context) {
    return ViewsProvider.of(context).emptyBuilder(context);
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      if (errorBuilder != null) {
        return errorBuilder(context, error);
      }
    } else if (isEmpty == true) {
      if (emptyBuilder != null) {
        return emptyBuilder(context);
      }
    } else if (progress != null) {
      if (loadingBuilder != null) {
        return loadingBuilder(context, progress);
      }
    }
    return builder(context);
  }
}
