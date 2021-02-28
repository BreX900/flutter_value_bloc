import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:provider/provider.dart';

/// It provider in [SingleViewValueCubitBuilder] or
/// [ListViewValueCubitBuilder] the defaults builders
class CubitViewsProvider extends Provider<CubitViews> {
  CubitViewsProvider({
    @required Create<CubitViews> create,
    TransitionBuilder builder,
    Widget child,
  }) : super(create: create, builder: builder, child: child);

  CubitViewsProvider.value({
    @required CubitViews value,
    TransitionBuilder builder,
    Widget child,
  }) : super.value(value: value, builder: builder, child: child);

  static CubitViews of(BuildContext context) => context.watch<CubitViews>();

  static CubitViews tryOf(BuildContext context) {
    try {
      return context.watch<CubitViews>();
    } on ProviderNotFoundException {
      return null;
    }
  }
}

extension CubitViewsProviderOnBuildContext on BuildContext {
  CubitViews cubitViews() => CubitViewsProvider.of(this);

  CubitViews tryCubitViews() => CubitViewsProvider.tryOf(this);
}
