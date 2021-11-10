import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

mixin BlocOnSingleChildWidget<TBloc extends BlocBase<dynamic>> on SingleChildStatefulWidget {
  TBloc? get bloc;
}

mixin BlocOnSingleChildState<TWidget extends BlocOnSingleChildWidget<TBloc>,
    TBloc extends BlocBase<dynamic>> on SingleChildState<TWidget> {
  late TBloc _bloc;
  TBloc get bloc => _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<TBloc>();
  }

  @override
  void didUpdateWidget(TWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<TBloc>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      final previousBloc = _bloc;
      _bloc = currentBloc;
      onUpdateBloc(previousBloc);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<TBloc>();
    if (_bloc != bloc) {
      final previousBloc = _bloc;
      _bloc = bloc;
      onUpdateBloc(previousBloc);
    }
  }

  void onUpdateBloc(TBloc oldBloc) {}

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (widget.bloc == null) context.select<TBloc, int>(identityHashCode);
    return child!;
  }
}
