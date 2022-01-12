import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rxdart/rxdart.dart';

class BlocGroupListener<TBloc extends BlocBase<TState>, TState> extends SingleChildStatelessWidget {
  final List<TBloc> blocs;
  final bool Function(TState previous, TState current)? listenWhen;
  final void Function(BuildContext context, TState state) listener;

  const BlocGroupListener({
    Key? key,
    required this.blocs,
    this.listenWhen,
    required this.listener,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: blocs.map((bloc) {
        return BlocListener<TBloc, TState>(
          bloc: bloc,
          listenWhen: listenWhen,
          listener: listener,
        );
      }).toList(),
      child: child,
    );
  }
}

class BlocGroupBuilder<TBloc extends BlocBase<TState>, TState> extends StatefulWidget {
  final List<TBloc> blocs;
  final bool Function(List<TState> previous, List<TState> current)? buildWhen;
  final Widget Function(BuildContext context, List<TState> states) builder;

  const BlocGroupBuilder({
    Key? key,
    required this.blocs,
    this.buildWhen,
    required this.builder,
  }) : super(key: key);

  @override
  _BlocGroupBuilderState<TBloc, TState> createState() => _BlocGroupBuilderState();
}

class _BlocGroupBuilderState<TBloc extends BlocBase<TState>, TState>
    extends State<BlocGroupBuilder<TBloc, TState>> {
  late StreamSubscription _statesSub;
  late List<TState> _states;

  @override
  void initState() {
    super.initState();
    _states = widget.blocs.map((bloc) => bloc.state).toList();
  }

  @override
  void didUpdateWidget(covariant BlocGroupBuilder<TBloc, TState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.blocs, oldWidget.blocs)) {
      _states = widget.blocs.map((bloc) => bloc.state).toList();
      _statesSub.cancel();
      _initStatesListener();
    }
  }

  @override
  void dispose() {
    _statesSub.cancel();
    super.dispose();
  }

  void _initStatesListener() {
    _statesSub = Rx.combineLatestList(widget.blocs.map((bloc) {
      return bloc.stream.startWith(bloc.state);
    })).listen((states) {
      setState(() {
        _states = states;
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, List.unmodifiable(_states));
}

class BlocGroupSelector<TBloc extends BlocBase<TState>, TState, TValue> extends StatefulWidget {
  final List<TBloc> blocs;
  final TValue Function(List<TState> states) selector;
  final Widget Function(BuildContext context, TValue value) builder;

  const BlocGroupSelector({
    Key? key,
    required this.blocs,
    required this.selector,
    required this.builder,
  }) : super(key: key);

  @override
  _BlocGroupSelectorState<TBloc, TState, TValue> createState() => _BlocGroupSelectorState();
}

class _BlocGroupSelectorState<TBloc extends BlocBase<TState>, TState, TValue>
    extends State<BlocGroupSelector<TBloc, TState, TValue>> {
  late StreamSubscription _statesSub;
  late TValue _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selector(widget.blocs.map((bloc) => bloc.state).toList());
  }

  @override
  void didUpdateWidget(covariant BlocGroupSelector<TBloc, TState, TValue> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.blocs, oldWidget.blocs)) {
      _value = widget.selector(widget.blocs.map((bloc) => bloc.state).toList());
      _statesSub.cancel();
      _initStatesListener();
    }
  }

  @override
  void dispose() {
    _statesSub.cancel();
    super.dispose();
  }

  void _initStatesListener() {
    _statesSub = Rx.combineLatestList(widget.blocs.map((bloc) => bloc.stream)).listen((states) {
      final value = widget.selector(states);
      setState(() {
        _value = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}
