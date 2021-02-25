import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/utils.dart';
import 'package:flutter_value_bloc/src/widgets/SmartRefresherCubitBuilder.dart';
import 'package:value_bloc/value_bloc.dart';

class ListViewCubitBuilder<Value> extends StatelessWidget {
  final IterableCubit<Value, Object> iterableCubit;

  /// [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// [ScrollView.reverse]
  final bool reverse;

  /// [ScrollView.controller]
  final ScrollController controller;

  /// [ScrollView.primary]
  final bool primary;

  /// [ScrollView.physics]
  final ScrollPhysics physics;

  /// [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  final ChildWidgetBuilder viewBuilder;

  /// [ListView.separatorBuilder]
  final IndexedWidgetBuilder separatorBuilder;

  /// [ListView.itemBuilder]
  final ObjectWidgetBuilder<Value> builder;

  const ListViewCubitBuilder({
    Key key,
    @required this.iterableCubit,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.viewBuilder,
    this.separatorBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>(
      cubit: iterableCubit,
      builder: (context, state) {
        if (state is IterableCubitIdle<Value, Object> ||
            (state is IterableCubitUpdating<Value, Object> && state.values.isEmpty)) {
          return Center(child: CircularProgressIndicator());
        } else if (state is IterableCubitUpdateFailed<Value, Object>) {
          return Text('Failed');
        } else if (state.values.isEmpty) {
          return Text('Empty');
        }

        final values = state.values;

        Widget itemBuilder(BuildContext context, int index) {
          return builder(context, values[index]);
        }

        final listView = separatorBuilder != null
            ? ListView.separated(
                scrollDirection: scrollDirection,
                reverse: reverse,
                controller: controller,
                primary: primary,
                physics: physics,
                shrinkWrap: shrinkWrap,
                itemCount: values.length,
                separatorBuilder: separatorBuilder,
                itemBuilder: itemBuilder,
              )
            : ListView.builder(
                scrollDirection: scrollDirection,
                reverse: reverse,
                controller: controller,
                primary: primary,
                physics: physics,
                shrinkWrap: shrinkWrap,
                itemCount: values.length,
                itemBuilder: itemBuilder,
              );

        return viewBuilder != null ? viewBuilder(context, listView) : listView;
      },
    );
  }
}

class SmartListViewCubitBuilder<Value> extends StatefulWidget {
  final MultiCubit<Value, Object, Object> multiCubit;

  /// [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// [ScrollView.reverse]
  final bool reverse;

  /// [ScrollView.controller]
  final ScrollController controller;

  /// [ScrollView.primary]
  final bool primary;

  /// [ScrollView.physics]
  final ScrollPhysics physics;

  /// [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  final int valuesPerScroll;
  final bool isEnabledPullDown;
  final bool isEnabledPullUp;

  /// [ListView.separatorBuilder]
  final IndexedWidgetBuilder separatorBuilder;

  /// [ListView.itemBuilder]
  final ObjectWidgetBuilder<Value> builder;

  const SmartListViewCubitBuilder({
    Key key,
    @required this.multiCubit,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.valuesPerScroll = 10,
    this.isEnabledPullDown = true,
    this.isEnabledPullUp = false,
    this.separatorBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  _SmartListViewCubitBuilderState<Value> createState() => _SmartListViewCubitBuilderState();
}

class _SmartListViewCubitBuilderState<Value> extends State<SmartListViewCubitBuilder<Value>> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant SmartListViewCubitBuilder<Value> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.multiCubit != oldWidget.multiCubit) {
      init();
    }
  }

  void init() {
    widget.multiCubit.fetch(section: IterableSection(0, widget.valuesPerScroll));
  }

  @override
  Widget build(BuildContext context) {
    return ListViewCubitBuilder(
      iterableCubit: widget.multiCubit,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      viewBuilder: (context, child) {
        return SmartRefresherCubitBuilder.multi(
          multiCubit: widget.multiCubit,
          valuesPerScroll: widget.valuesPerScroll,
          isEnabledPullDown: widget.isEnabledPullDown,
          isEnabledPullUp: widget.isEnabledPullUp,
          child: child,
        );
      },
      separatorBuilder: widget.separatorBuilder,
      builder: widget.builder,
    );
  }
}
