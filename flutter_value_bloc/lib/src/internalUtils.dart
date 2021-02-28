import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewCubitInitializer<C extends Cubit<Object>> extends StatefulWidget {
  final C cubit;
  final void Function(BuildContext context, C cubit) initializer;
  final Widget child;

  const ViewCubitInitializer({
    Key key,
    @required this.cubit,
    @required this.initializer,
    @required this.child,
  })  : assert(cubit != null),
        assert(initializer != null),
        assert(child != null),
        super(key: key);

  @override
  _ViewCubitInitializerState<C> createState() => _ViewCubitInitializerState();
}

class _ViewCubitInitializerState<C extends Cubit<Object>> extends State<ViewCubitInitializer<C>> {
  @override
  void initState() {
    super.initState();
    widget.initializer(context, widget.cubit);
  }

  @override
  void didUpdateWidget(covariant ViewCubitInitializer<C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cubit != oldWidget.cubit) {
      widget.initializer(context, widget.cubit);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
