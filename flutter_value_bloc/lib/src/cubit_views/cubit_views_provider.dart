import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/cubit_views/cubit_views.dart';
import 'package:provider/provider.dart';

/// It provider in [SingleViewValueCubitBuilder] or
/// [ListViewValueCubitBuilder] the defaults builders
class CubitViewsProvider extends Provider<CubitViews> {
  CubitViewsProvider({
    Key? key,
    required Create<CubitViews> create,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(key: key, create: create, builder: builder, child: child);

  CubitViewsProvider.value({
    Key? key,
    required CubitViews value,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(key: key, value: value, builder: builder, child: child);

  static CubitViews of(BuildContext context) => context.watch<CubitViews>();

  static CubitViews? tryOf(BuildContext context) {
    try {
      return context.watch<CubitViews>();
    } on ProviderNotFoundException {
      return null;
    }
  }
}

extension CubitViewsProviderOnBuildContext on BuildContext {
  CubitViews cubitViews() => CubitViewsProvider.of(this);

  CubitViews? tryCubitViews() => CubitViewsProvider.tryOf(this);
}
