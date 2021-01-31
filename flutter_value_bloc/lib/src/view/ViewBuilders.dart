import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/view/ViewData.dart';
import 'package:flutter_value_bloc/src/view/ViewProvider.dart';

/// This is a view builder with default [ViewErrorBuilder],
/// [ViewLoaderBuilder], [ViewEmptyBuilder]
class ViewBuilder extends StatelessWidget {
  final double progress;
  final bool isEmpty;
  final Object error;
  final ViewErrorBuilder errorBuilder;
  final ViewLoaderBuilder loadingBuilder;
  final ViewEmptyBuilder emptyBuilder;
  final WidgetBuilder builder;

  const ViewBuilder({
    Key key,
    this.progress,
    this.isEmpty = false,
    this.error,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final view = ViewDataProvider.of(context).copyWith(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
    );

    if (error != null) {
      if (view.errorBuilder != null) {
        return view.errorBuilder(context, error);
      }
    } else if (isEmpty == true) {
      if (view.emptyBuilder != null) {
        return view.emptyBuilder(context);
      }
    } else if (progress != null && view.loadingBuilder != null) {
      return view.loadingBuilder(context, progress);
    }
    return builder(context);
  }
}
