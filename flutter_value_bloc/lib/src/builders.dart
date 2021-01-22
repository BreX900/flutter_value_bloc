import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

/// it extends [BlocBuilder] for use with [ValueCubit]
class SingleValueCubitBuilder<C extends ValueCubit<V, Filter>, V, Filter>
    extends BlocBuilder<C, SingleValueState<V, Filter>> {
  SingleValueCubitBuilder({
    C cubit,
    BlocBuilderCondition<SingleValueState<V, Filter>> buildWhen,
    @required BlocWidgetBuilder<SingleValueState<V, Filter>> builder,
  }) : super(
          cubit: cubit,
          buildWhen: buildWhen,
          builder: builder,
        );
}

/// it extends [BlocBuilder] for use with [ListValueCubitBuilder]
class ListValueCubitBuilder<C extends ListValueCubit<V, Filter>, V, Filter>
    extends BlocBuilder<C, ListValueState<V, Filter>> {
  ListValueCubitBuilder({
    C cubit,
    BlocBuilderCondition<ListValueState<V, Filter>> buildWhen,
    @required BlocWidgetBuilder<ListValueState<V, Filter>> builder,
  }) : super(
          cubit: cubit,
          buildWhen: buildWhen,
          builder: builder,
        );
}
