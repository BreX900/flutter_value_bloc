import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/value/ViewData.dart';
import 'package:flutter_value_bloc/src/value/ViewProvider.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class ViewValueCubitPlugin<C extends ValueCubit<S, Filter>,
    S extends ValueState<Filter>, Filter> {
  Widget apply(C valueCubit, S builderState, Widget child);
}

class ViewSingleValueCubitBuilder<C extends SingleValueCubit<V, Filter>, V, Filter>
    extends ViewValueCubitBuilderBase<C, SingleValueState<V, Filter>> {
  const ViewSingleValueCubitBuilder({
    Key key,
    C valueCubit,
    ViewValueCubitPlugin plugin,
    ViewErrorBuilder errorBuilder,
    ViewLoaderBuilder loadingBuilder,
    ViewEmptyBuilder emptyBuilder,
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

class ViewListValueCubitBuilder<C extends ListValueCubit<V, Filter>, V, Filter>
    extends ViewValueCubitBuilderBase<C, ListValueState<V, Filter>> {
  const ViewListValueCubitBuilder({
    Key key,
    C valueCubit,
    ViewValueCubitPlugin plugin,
    ViewErrorBuilder errorBuilder,
    ViewLoaderBuilder loadingBuilder,
    ViewEmptyBuilder emptyBuilder,
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

class ViewValueCubitBuilderBase<C extends ValueCubit<S, dynamic>,
    S extends ValueState<dynamic>> extends StatelessWidget {
  final C valueCubit;
  final ViewValueCubitPlugin plugin;
  final ViewErrorBuilder errorBuilder;
  final ViewLoaderBuilder loadingBuilder;
  final ViewEmptyBuilder emptyBuilder;
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

    final view = ViewDataProvider.tryOf(context).copyWith(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
    );

    return BlocBuilder<C, S>(
      cubit: valueCubit,
      builder: (context, state) {
        /// build a error widget if the state have a error
        if (state is FailedValueState) {
          if (view.errorBuilder != null) {
            return view.errorBuilder(context, state.error);
          }
        } else if (!state.isInitialized) {
          /// build a loading widget if the state is not initilized
          double progress;
          if (state is ProcessingValueState) {
            progress = state.progress;
          } else if (state is LoadedValueState) {
            progress = 0.0;
          }
          if (progress != null && view.loadingBuilder != null) {
            return view.loadingBuilder(context, progress);
          }
        } else if (state.isEmpty) {
          /// build a empty widget if the state not have a value/s
          if (view.emptyBuilder != null) {
            return view.emptyBuilder(context);
          }
        }
        final child = builder(context, state);

        if (plugin != null) {
          return plugin.apply(valueCubit, state, child);
        }

        return child;
      },
    );
  }
}

class ViewBuilder extends StatelessWidget {
  final double progress;
  final bool isEmpty;
  final Object error;
  final ViewErrorBuilder errorBuilder;
  final ViewLoaderBuilder loadingBuilder;
  final ViewEmptyBuilder emptyBuilder;
  final WidgetBuilder builder;

  const ViewBuilder({
    Key key,
    this.progress,
    this.isEmpty = false,
    this.error,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final view = ViewDataProvider.tryOf(context).copyWith(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
    );

    if (error != null) {
      if (view.errorBuilder != null) {
        return view.errorBuilder(context, error);
      }
    } else if (isEmpty == true) {
      if (view.emptyBuilder != null) {
        return view.emptyBuilder(context);
      }
    } else if (progress != null && view.loadingBuilder != null) {
      return view.loadingBuilder(context, progress);
    }
    return builder(context);
  }
}
