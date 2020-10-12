import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/RefresherValueCubitBuilder.dart';
import 'package:provider/provider.dart';
import 'package:value_bloc/value_bloc.dart';

typedef LoadingBuilder = Widget Function(BuildContext context, double progress);
typedef ErrorBuilder = Widget Function(BuildContext context, Object error);
typedef EmptyBuilder = Widget Function(BuildContext context);

class ViewData {
  final ErrorBuilder errorBuilder;
  final LoadingBuilder loadingBuilder;
  final EmptyBuilder emptyBuilder;

  const ViewData({
    this.errorBuilder = _buildError,
    this.loadingBuilder = _buildLoading,
    this.emptyBuilder = _buildEmpty,
  });

  const ViewData.raw({
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  static Widget _buildError(BuildContext context, Object error) {
    return Text('$error');
  }

  static Widget _buildLoading(BuildContext context, double progress) {
    return CircularProgressIndicator(value: progress == 0.0 ? null : progress);
  }

  static Widget _buildEmpty(BuildContext context) {
    return Text('Empty');
  }

  ViewData copyWith({
    LoadingBuilder loadingBuilder,
    ErrorBuilder errorBuilder,
    EmptyBuilder emptyBuilder,
  }) {
    return new ViewData.raw(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }
}

class ViewValueCubitBuilder<C extends ValueCubit<S, dynamic>,
    S extends ValueState<dynamic>> extends StatelessWidget {
  final C valueCubit;
  final ErrorBuilder errorBuilder;
  final LoadingBuilder loadingBuilder;
  final EmptyBuilder emptyBuilder;
  final BlocWidgetBuilder<S> builder;

  const ViewValueCubitBuilder({
    Key key,
    this.valueCubit,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    @required this.builder,
  }) : super(key: key);

  ViewValueCubitBuilder.refresher({
    C valueCubit,
    ErrorBuilder errorBuilder,
    LoadingBuilder loadingBuilder,
    EmptyBuilder emptyBuilder,
    bool enablePullDown = true,
    bool enablePullUp = true,
    @required BlocWidgetBuilder<S> builder,
  }) : this(
          valueCubit: valueCubit,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          builder: (context, state) {
            return RefresherValueCubitBuilder(
              valueCubit: valueCubit ?? context.bloc<C>(),
              enablePullDown: enablePullDown,
              enablePullUp: enablePullUp,
              child: builder(context, state),
            );
          },
        );

  @override
  Widget build(BuildContext context) {
    final view = ViewDataProvider._tryOf(context).copyWith(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
    );

    return BlocBuilder<C, S>(
      cubit: valueCubit,
      builder: (context, state) {
        if (state is FailureValueState) {
          if (view.errorBuilder != null) {
            return view.errorBuilder(context, state.error);
          }
        } else if (state.isEmpty == true) {
          if (view.emptyBuilder != null) {
            return view.emptyBuilder(context);
          }
        } else if (state.isEmpty == null) {
          double progress;
          if (state is ProcessingValueState) {
            progress = state.progress;
          } else if (state is SuccessLoadedValueState) {
            progress = 0.0;
          }
          if (progress != null && view.loadingBuilder != null) {
            return view.loadingBuilder(context, progress);
          }
        }
        return builder(context, state);
      },
    );
  }
}

class ViewDataProvider extends Provider<ViewData> {
  ViewDataProvider({
    @required Create<ViewData> create,
    TransitionBuilder builder,
    Widget child,
  }) : super(create: create, builder: builder, child: child);

  ViewDataProvider.value({
    @required ViewData value,
    TransitionBuilder builder,
    Widget child,
  }) : super.value(value: value, builder: builder, child: child);

  static ViewData of(BuildContext context) => context.watch<ViewData>();

  static ViewData _tryOf(BuildContext context) {
    try {
      return context.watch<ViewData>();
    } on ProviderNotFoundException {
      return const ViewData();
    }
  }
}
