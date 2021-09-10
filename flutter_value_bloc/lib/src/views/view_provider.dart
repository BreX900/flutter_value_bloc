import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/views/view_data.dart';
import 'package:provider/provider.dart';

/// It provider in [ViewBuilder], [SingleViewValueCubitBuilder] or
/// [ListViewValueCubitBuilder] the defaults builders
class ViewsProvider<TFailure> extends Provider<Views<TFailure>> {
  ViewsProvider({
    Key? key,
    required Create<Views<TFailure>> create,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(key: key, create: create, builder: builder, child: child);

  ViewsProvider.value({
    Key? key,
    required Views<TFailure> value,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(key: key, value: value, builder: builder, child: child);

  static Views<TFailure> of<TFailure>(BuildContext context) {
    return context.read<Views<TFailure>>();
  }

  static Views<TFailure> from<TFailure>(BuildContext context) {
    try {
      return context.read<Views<TFailure>>();
    } on ProviderNotFoundException {
      return const Views();
    }
  }

  static Views<TFailure>? maybeOf<TFailure>(BuildContext context) {
    try {
      return context.read<Views<TFailure>>();
    } on ProviderNotFoundException {
      return null;
    }
  }
}

extension ViewsProviderOnBuildContext on BuildContext {
  Views views() => ViewsProvider.of(this);

  Views? maybeViews() => ViewsProvider.maybeOf(this);
}
