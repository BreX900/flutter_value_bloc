import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/value/ViewData.dart';
import 'package:provider/provider.dart';

class ViewDataProvider extends Provider<ViewData> {
  ViewDataProvider({
    @required Create<ViewData> create,
    TransitionBuilder builder,
    Widget child,
  }) : super(create: create, builder: builder, child: child);

  ViewDataProvider.value({
    @required ViewData value,
    TransitionBuilder builder,
    Widget child,
  }) : super.value(value: value, builder: builder, child: child);

  static ViewData of(BuildContext context) => context.watch<ViewData>();

  static ViewData tryOf(BuildContext context) {
    try {
      return context.watch<ViewData>();
    } on ProviderNotFoundException {
      return const ViewData();
    }
  }
}