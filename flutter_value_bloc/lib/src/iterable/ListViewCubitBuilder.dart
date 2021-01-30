import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

typedef ValueWidgetBuilder<V> = Widget Function(BuildContext context, V value);

class ListViewCubitBuilder<V> extends StatelessWidget {
  final IterableCubit<V, Object> iterableCubit;

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

  /// [ListView.separatorBuilder]
  final IndexedWidgetBuilder separatorBuilder;

  /// [ListView.itemBuilder]
  final ValueWidgetBuilder builder;

  const ListViewCubitBuilder({
    Key key,
    @required this.iterableCubit,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.separatorBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IterableCubit<V, Object>, IterableCubitState<V, Object>>(
      builder: (context, state) {
        final values = state.values;

        Widget itemBuilder(BuildContext context, int index) {
          return builder(context, values[index]);
        }

        if (separatorBuilder != null) {
          return ListView.separated(
            scrollDirection: scrollDirection,
            itemCount: values.length,
            separatorBuilder: separatorBuilder,
            itemBuilder: itemBuilder,
          );
        }

        return ListView.builder(
          scrollDirection: scrollDirection,
          itemCount: values.length,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
