import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/view/ViewData.dart';
import 'package:provider/provider.dart';

/// It provider in [ViewBuilder], [SingleViewValueCubitBuilder] or
/// [ListViewValueCubitBuilder] the defaults builders
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

  static ViewData of(BuildContext context, {bool nullOk = false}) {
    try {
      return context.watch<ViewData>();
    } on ProviderNotFoundException {
      if (nullOk) {
        return null;
      } else {
        rethrow;
      }
    }
  }
}
