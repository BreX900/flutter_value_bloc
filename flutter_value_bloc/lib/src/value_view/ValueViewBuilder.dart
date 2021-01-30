import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/value_view/ValueViewProvider.dart';
import 'package:value_bloc/value_bloc.dart';

/// it is a [DynamicCubitBuilder] for [ValueCubit]
class SingleViewValueCubitBuilder<C extends ValueCubit<V, Filter>, V, Filter>
    extends DynamicCubitBuilder<C, SingleValueState<V, Filter>> {
  const SingleViewValueCubitBuilder({
    Key key,
    C valueCubit,
    ViewValueCubitPlugin plugin,
    BlocWidgetBuilder<FailedValueState> errorBuilder,
    BlocWidgetBuilder<ProcessingValueState> loadingBuilder,
    BlocWidgetBuilder<ValueState> emptyBuilder,
    BlocWidgetBuilder<SingleValueState<V, Filter>> builder,
  }) : super(
          key: key,
          valueCubit: valueCubit,
          plugin: plugin,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          builder: builder,
        );
}

/// it is a [DynamicCubitBuilder] for [ListValueCubit]
class ListViewValueCubitBuilder<C extends IterableCubit<V, Object>, V>
    extends DynamicCubitBuilder<C, IterableCubitState<V, Object>> {
  const ListViewValueCubitBuilder({
    Key key,
    C valueCubit,
    ViewValueCubitPlugin plugin,
    BlocWidgetBuilder<FailedValueState> errorBuilder,
    BlocWidgetBuilder<ProcessingValueState> loadingBuilder,
    BlocWidgetBuilder<ValueState> emptyBuilder,
    BlocWidgetBuilder<ListValueState<V, Filter>> builder,
  }) : super(
          key: key,
          valueCubit: valueCubit,
          plugin: plugin,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          builder: builder,
        );
}

/// This is a plugin for wrapping a child in [DynamicCubitBuilder]
abstract class ViewValueCubitPlugin<C extends ValueCubit<S, Filter>, S extends ValueState<Filter>,
    Filter> {
  Widget apply(C valueCubit, S builderState, Widget child);
}

/// Prefer use [SingleViewValueCubitBuilder] or [ListViewValueCubitBuilder]
///
/// This is a view builder with default [ValueViewErrorBuilder],
/// [ValueViewLoaderBuilder], [ValueViewEmptyBuilder] for [ValueCubit]
abstract class DynamicCubitBuilder<C extends Cubit<S>, S> extends StatelessWidget {
  final C valueCubit;
  final ViewValueCubitPlugin plugin;
  final BlocWidgetBuilder<FailedValueState> errorBuilder;
  final BlocWidgetBuilder<ProcessingValueState> loadingBuilder;
  final BlocWidgetBuilder<ValueState> emptyBuilder;
  final BlocWidgetBuilder<S> builder;

  const DynamicCubitBuilder({
    Key key,
    this.plugin,
    this.valueCubit,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    @required this.builder,
  }) : super(key: key);

  bool isLoading(BuildContext context, S state);

  bool isFailed(BuildContext context, S state);

  bool isEmpty(BuildContext context, S state);

  @override
  Widget build(BuildContext context) {
    final valueCubit = this.valueCubit ?? BlocProvider.of<C>(context);
    assert(valueCubit != null);

    final view = ValueViewDataProvider.tryOf(context).copyWith(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
    );

    return BlocBuilder<C, S>(
      cubit: valueCubit,
      builder: (context, state) {
        Widget current;

        /// build a error widget if the state have a error
        if (isFailed(context, state)) {
          current = view.errorBuilder(context, state);
        } else if (isLoading(context, state)) {
          /// build a loading widget if the state is not initilized
          current = view.loadingBuilder(context, state);
        } else if (isEmpty(context, state)) {
          /// build a empty widget if the state not have a value/s
          current = view.emptyBuilder(context, state);
        } else if (plugin != null) {
          current = plugin.apply(valueCubit, state, builder(context, state));
        }
        current ??= builder(context, state);

        return current;
      },
    );
  }
}
