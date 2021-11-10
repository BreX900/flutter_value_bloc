import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

class RefreshBuilder<TFailure extends Object> extends StatefulWidget {
  final List<BlocBase<DataBlocState<dynamic, TFailure>>> blocs;

  // ========== SmartRefresher ====================

  /// [SmartRefresher.scrollController]
  final ScrollController? scrollController;

  /// [SmartRefresher.scrollDirection]
  final Axis? scrollDirection;

  /// [SmartRefresher.reverse]
  final bool? reverse;

  /// [SmartRefresher.primary]
  final bool? primary;

  /// [SmartRefresher.physics]
  final ScrollPhysics? physics;

  /// [SmartRefresher.cacheExtent]
  final double? cacheExtent;

  /// [SmartRefresher.semanticChildCount]
  final int? semanticChildCount;

  /// [SmartRefresher.dragStartBehavior]
  final DragStartBehavior? dragStartBehavior;

  /// [SmartRefresher.onRefresh]
  final VoidCallback onRefresh;

  /// [SmartRefresher.child]
  final Widget child;

  const RefreshBuilder({
    Key? key,
    required this.blocs,
    this.scrollController,
    this.scrollDirection,
    this.reverse,
    this.primary,
    this.physics,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  _RefreshBuilderState<TFailure> createState() => _RefreshBuilderState();
}

class _RefreshBuilderState<TFailure extends Object> extends State<RefreshBuilder<TFailure>> {
  final _controller = RefreshController();

  bool _isRefreshing = false;
  late bool _canRefresh;
  late final StreamSubscription _canRefreshSub;

  StreamSubscription? _refreshResultSub;

  bool get _enablePullDown => _isRefreshing || _canRefresh;

  @override
  void initState() {
    super.initState();
    _canRefresh = _checkCanRefresh(widget.blocs.map((bloc) => bloc.state));
    _initCanRefreshListener();
  }

  @override
  void didUpdateWidget(covariant RefreshBuilder<TFailure> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(listEquals(widget.blocs, oldWidget.blocs), 'Not change blocs list');
  }

  @override
  void dispose() {
    _canRefreshSub.cancel();
    _refreshResultSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _checkCanRefresh(Iterable<DataBlocState<dynamic, TFailure>> states) {
    return states.every((state) {
      if (state.isUpdating) return false;
      return state.hasFailure || state.hasData;
    });
  }

  void _initCanRefreshListener() {
    _canRefreshSub = Rx.combineLatestList(widget.blocs.map((bloc) {
      // Cast is required
      return bloc.stream.cast<DataBlocState<dynamic, TFailure>>().startWith(bloc.state);
    })).listen((states) {
      final canRefresh = _checkCanRefresh(states);
      _update(canRefresh: canRefresh);
    });
  }

  void _initRefreshResultListener() {
    // Catch only states with value or failure without emitting state
    _refreshResultSub = Rx.combineLatestList(widget.blocs.map((bloc) {
      return bloc.stream.where((state) => !state.isUpdating);
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
            views.failureListener(context, state.failure!);
          }
        }
      }
      _refreshResultSub?.cancel();
      _update(isRefreshing: false);
    });
  }

  void _refresh() {
    _update(isRefreshing: true);
    _initRefreshResultListener();
    widget.onRefresh();
  }

  void _update({bool? isRefreshing, bool? canRefresh}) {
    final enablePullDown = _enablePullDown;
    _isRefreshing = isRefreshing ?? _isRefreshing;
    _canRefresh = canRefresh ?? _canRefresh;
    if (enablePullDown != _enablePullDown) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Not use SmartRefresher on desktop platform
    return SmartRefresher(
      controller: _controller,
      enablePullDown: _enablePullDown,
      onRefresh: _refresh,
      scrollController: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      child: widget.child,
    );
  }
}