import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewCubitInitializer<C extends Cubit<S>, S> extends StatefulWidget {
  final C cubit;
  final bool Function(S state) initializeWhen;
  final void Function(BuildContext context, C cubit) initializer;
  final Widget child;

  const ViewCubitInitializer({
    Key? key,
    required this.cubit,
    required this.initializeWhen,
    required this.initializer,
    required this.child,
  }) : super(key: key);

  @override
  _ViewCubitInitializerState<C, S> createState() => _ViewCubitInitializerState();
}

class _ViewCubitInitializerState<C extends Cubit<S>, S> extends State<ViewCubitInitializer<C, S>> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void didUpdateWidget(covariant ViewCubitInitializer<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cubit != oldWidget.cubit) {
      initialize();
    }
  }

  void initialize() {
    if (widget.initializeWhen(widget.cubit.state)) {
      widget.initializer(context, widget.cubit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, S>(
      bloc: widget.cubit,
      listenWhen: (p, c) => p.runtimeType != c.runtimeType,
      listener: (context, state) => initialize(),
      child: widget.child,
    );
  }
}
