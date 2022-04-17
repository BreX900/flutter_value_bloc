import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/views/ViewData.dart';
import 'package:provider/provider.dart';

/// It provider in [ViewBuilder], [SingleViewValueCubitBuilder] or
/// [ListViewValueCubitBuilder] the defaults builders
class ViewsProvider extends Provider<Views> {
  ViewsProvider({
    required Create<Views> create,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(create: create, builder: builder, child: child);

  ViewsProvider.value({
    required Views value,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(data: value, builder: builder, child: child);

  static Views of(BuildContext context) {
    return context.watch<Views>();
  }

  static Views? tryOf(BuildContext context) {
    try {
      return context.watch<Views>();
    } on ProviderNotFoundException {
      return null;
    }
  }
}

extension ViewsProviderOnBuildContext on BuildContext {
  Views views() => ViewsProvider.of(this);

  Views? tryViews() => ViewsProvider.tryOf(this);
}
