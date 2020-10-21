import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/value_view/ValueViewProvider.dart';
import 'package:value_bloc/value_bloc.dart';

/// it is a [ViewValueCubitBuilderBase] for [SingleValueCubit]
class SingleViewValueCubitBuilder<C extends SingleValueCubit<V, Filter>, V, Filter>
    extends ViewValueCubitBuilderBase<C, SingleValueState<V, Filter>> {
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

/// it is a [ViewValueCubitBuilderBase] for [ListValueCubit]
class ListViewValueCubitBuilder<C extends ListValueCubit<V, Filter>, V, Filter>
    extends ViewValueCubitBuilderBase<C, ListValueState<V, Filter>> {
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

/// This is a plugin for wrapping a child in [ViewValueCubitBuilderBase]
abstract class ViewValueCubitPlugin<C extends ValueCubit<S, Filter>,
    S extends ValueState<Filter>, Filter> {
  Widget apply(C valueCubit, S builderState, Widget child);
}

/// Prefer use [SingleViewValueCubitBuilder] or [ListViewValueCubitBuilder]
///
/// This is a view builder with default [ValueViewErrorBuilder],
/// [ValueViewLoaderBuilder], [ValueViewEmptyBuilder] for [ValueCubit]
class ViewValueCubitBuilderBase<C extends ValueCubit<S, dynamic>,
    S extends ValueState<dynamic>> extends StatelessWidget {
  final C valueCubit;
  final ViewValueCubitPlugin plugin;
  final BlocWidgetBuilder<FailedValueState> errorBuilder;
  final BlocWidgetBuilder<ProcessingValueState> loadingBuilder;
  final BlocWidgetBuilder<ValueState> emptyBuilder;
  final BlocWidgetBuilder<S> builder;

  const ViewValueCubitBuilderBase({
    Key key,
    this.plugin,
    this.valueCubit,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueCubit = this.valueCubit ?? context.bloc<C>();
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
        if (state is FailedValueState) {
          current = view.errorBuilder(context, state.error);
        } else if (!state.isInitialized) {
          /// build a loading widget if the state is not initilized
          current = view.loadingBuilder(context, state);
        } else if (state.isEmpty) {
          /// build a empty widget if the state not have a value/s
          current = view.emptyBuilder(context, state);
        }

        current ??= builder(context, state);

        if (plugin != null) current = plugin.apply(valueCubit, state, current);

        return current;
      },
    );
  }
}
