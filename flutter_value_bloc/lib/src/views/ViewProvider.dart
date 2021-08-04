import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/views/ViewData.dart';
import 'package:provider/provider.dart';

/// It provider in [ViewBuilder], [SingleViewValueCubitBuilder] or
/// [ListViewValueCubitBuilder] the defaults builders
class ViewsProvider<TFailure> extends Provider<Views<TFailure>> {
  ViewsProvider({
    required Create<Views<TFailure>> create,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(create: create, builder: builder, child: child);

  ViewsProvider.value({
    required Views<TFailure> value,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(value: value, builder: builder, child: child);

  static Views<TFailure> of<TFailure>(BuildContext context) {
    return context.watch<Views<TFailure>>();
  }

  static Views<TFailure>? maybeOf<TFailure>(BuildContext context) {
    try {
      return context.watch<Views<TFailure>>();
    } on ProviderNotFoundException {
      return null;
    }
  }
}

extension ViewsProviderOnBuildContext on BuildContext {
  Views views() => ViewsProvider.of(this);

  Views? maybeViews() => ViewsProvider.maybeOf(this);
}
