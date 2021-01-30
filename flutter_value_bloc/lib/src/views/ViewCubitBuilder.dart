import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

abstract class ViewCubitBuilder<S> extends StatefulWidget {
  final DynamicCubit<S> dynamicCubit;
  final ViewValueCubitPlugin plugin;
  final BlocWidgetBuilder<FailedValueState> errorBuilder;
  final BlocWidgetBuilder<ProcessingValueState> loadingBuilder;
  final BlocWidgetBuilder<ValueState> emptyBuilder;
  final BlocWidgetBuilder<S> builder;

  const ViewCubitBuilder({
    Key key,
    this.plugin,
    @required this.dynamicCubit,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    @required this.builder,
  }) : super(key: key);

  @override
  _ViewCubitBuilderState<S> createState() => _ViewCubitBuilderState<S>();
}

class _ViewCubitBuilderState<S> extends State<ViewCubitBuilder<S>> {
  @override
  void initState() {
    super.initState();
  }

  bool isUpdating(BuildContext context, S state) {
    if (state is ObjectCubitState) {
      if (state is ObjectCubitUpdating || state is ObjectCubitIdle) {
        return true;
      }
    } else if (state is IterableCubitState) {
      if (state is IterableCubitUpdating) {
        if (state.values == "ciao") return true;
      } else if (state is IterableCubitIdle) {}
    }
    return false;
  }

  bool isFailed(BuildContext context, S state);

  bool isEmpty(BuildContext context, S state);

  @override
  Widget build(BuildContext context) {
    final valueCubit = this.widget.dynamicCubit ?? BlocProvider.of<C>(context);
    assert(valueCubit != null);

    final view = ValueViewDataProvider.tryOf(context).copyWith(
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
      emptyBuilder: widget.emptyBuilder,
    );

    return BlocConsumer<DynamicCubit<S>, S>(
      cubit: valueCubit,
      listener: (context, state) {},
      builder: (context, state) {
        Widget current;

        /// build a error widget if the state have a error
        if (isFailed(context, state)) {
          current = view.errorBuilder(context, state);
        } else if (isUpdating(context, state)) {
          /// build a loading widget if the state is not initilized
          current = view.loadingBuilder(context, state);
        } else if (isEmpty(context, state)) {
          /// build a empty widget if the state not have a value/s
          current = view.emptyBuilder(context, state);
        } else if (widget.plugin != null) {
          current = widget.plugin.apply(valueCubit, state, widget.builder(context, state));
        }
        current ??= widget.builder(context, state);

        return current;
      },
    );
  }
}
