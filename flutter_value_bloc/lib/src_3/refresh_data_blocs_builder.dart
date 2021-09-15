import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/flutter_value_bloc_3.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

class RefreshGroupDataBlocBuilder<TFailure> extends StatefulWidget {
  final List<DataBloc<TFailure, dynamic, dynamic, DataBlocState<TFailure, dynamic>>> dataBlocs;
  final VoidCallback? onRefresh;
  final Widget child;

  const RefreshGroupDataBlocBuilder({
    Key? key,
    required this.dataBlocs,
    this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  _RefreshGroupDataBlocBuilderState<TFailure> createState() => _RefreshGroupDataBlocBuilderState();
}

class _RefreshGroupDataBlocBuilderState<TFailure>
    extends State<RefreshGroupDataBlocBuilder<TFailure>> {
  late RefreshController _controller;

  late final StreamSubscription _canRefreshSub;
  late bool _canRefresh;

  StreamSubscription? _refreshResultSub;

  @override
  void initState() {
    super.initState();
    _controller = RefreshController();
    _canRefresh = _checkCanRefresh(widget.dataBlocs.map((bloc) => bloc.state));
    _initCanRefreshListener();
  }

  @override
  void didUpdateWidget(covariant RefreshGroupDataBlocBuilder<TFailure> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(listEquals(widget.dataBlocs, oldWidget.dataBlocs), 'Not change data blocs list');
  }

  @override
  void dispose() {
    _canRefreshSub.cancel();
    _refreshResultSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _checkCanRefresh(Iterable<DataBlocState<TFailure, dynamic>> states) {
    return states.every((state) {
      if (state.isEmitting) return false;
      return state.hasFailure || state.hasData;
    });
  }

  void _initCanRefreshListener() {
    _canRefreshSub = Rx.combineLatestList(widget.dataBlocs.map((bloc) {
      // Cast is required
      return bloc.stream.cast<DataBlocState<TFailure, dynamic>>().startWith(bloc.state);
    })).listen((states) {
      final canRefresh = _checkCanRefresh(states);
      if (_canRefresh == canRefresh) return;
      setState(() {
        _canRefresh = canRefresh;
      });
    });
  }

  void _initRefreshResultListener() {
    // Catch only states with value or failure without emitting state
    _refreshResultSub = Rx.combineLatestList(widget.dataBlocs.map((bloc) {
      return bloc.stream.where((state) => !state.isEmitting);
    })).where((states) {
      return states.every((state) => state.hasFailure || state.hasData);
    }).listen((states) {
      // If all states have only a value notify success else notify a failure
      final hasValues = states.every((state) => state.hasData && !state.hasFailure);
      if (hasValues) {
        _controller.refreshCompleted();
      } else {
        _controller.refreshFailed();

        // Show failure message
        final views = ViewsProvider.from<TFailure>(context);
        for (final state in states) {
          if (state.hasFailure) {
            views.failureListener(context, state.failure);
          }
        }
      }
      _refreshResultSub?.cancel();
    });
  }

  void refresh() {
    for (final dataBloc in widget.dataBlocs) {
      dataBloc.read(canForce: true);
    }
    _initRefreshResultListener();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      enablePullDown: (_controller.headerStatus == RefreshStatus.refreshing) || _canRefresh,
      onRefresh: refresh,
      child: widget.child,
    );
  }
}
