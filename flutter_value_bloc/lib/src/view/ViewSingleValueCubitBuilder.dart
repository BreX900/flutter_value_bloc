import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class ViewSingleValueCubitBuilder<C extends SingleValueCubit<V, Filter>, V, Filter>
    extends ViewValueCubitBuilder<C, SingleValueState<V, Filter>> {
  const ViewSingleValueCubitBuilder({
    Key key,
    C valueCubit,
    RefresherPlugin refresherPlugin,
    ErrorBuilder errorBuilder,
    LoadingBuilder loadingBuilder,
    EmptyBuilder emptyBuilder,
    BlocWidgetBuilder<SingleValueState<V, Filter>> builder,
  }) : super(
          key: key,
          valueCubit: valueCubit,
          refresherPlugin: refresherPlugin,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          builder: builder,
        );
}

class ViewListValueCubitBuilder<C extends ListValueCubit<V, Filter>, V, Filter>
    extends ViewValueCubitBuilder<C, ListValueState<V, Filter>> {
  const ViewListValueCubitBuilder({
    Key key,
    C valueCubit,
    RefresherPlugin refresherPlugin,
    ErrorBuilder errorBuilder,
    LoadingBuilder loadingBuilder,
    EmptyBuilder emptyBuilder,
    BlocWidgetBuilder<ListValueState<V, Filter>> builder,
  }) : super(
          key: key,
          valueCubit: valueCubit,
          refresherPlugin: refresherPlugin,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          builder: builder,
        );
}
