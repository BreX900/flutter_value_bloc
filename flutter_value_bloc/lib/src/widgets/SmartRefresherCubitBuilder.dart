import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class SmartRefresherCubitBuilder extends StatefulWidget {
  final bool isEnabledPullDown;
  final bool isEnabledPullUp;
  final Widget child;

  const SmartRefresherCubitBuilder._({
    @required Key key,
    @required this.isEnabledPullDown,
    @required this.isEnabledPullUp,
    @required this.child,
  }) : super(key: key);

  factory SmartRefresherCubitBuilder.single({
    Key key,
    @required SingleCubit<Object, Object, Object> singleCubit,
    bool isEnabledPullDown,
    bool isEnabledPullUp,
    @required Widget child,
  }) = _SmartRefresherSingleCubitBuilder;

  factory SmartRefresherCubitBuilder.multi({
    Key key,
    @required MultiCubit<Object, Object, Object> multiCubit,
    int valuesPerScroll,
    bool isEnabledPullDown,
    bool isEnabledPullUp,
    @required Widget child,
  }) = _SmartRefresherMultiCubitBuilder;
}

class _SmartRefresherSingleCubitBuilder extends SmartRefresherCubitBuilder {
  final SingleCubit<Object, Object, Object> singleCubit;

  const _SmartRefresherSingleCubitBuilder({
    Key key,
    @required this.singleCubit,
    bool isEnabledPullDown = true,
    bool isEnabledPullUp = false,
    @required Widget child,
  }) : super._(
          key: key,
          isEnabledPullDown: isEnabledPullDown,
          isEnabledPullUp: isEnabledPullUp,
          child: child,
        );

  @override
  _SmartRefresherSingleCubitBuilderState createState() => _SmartRefresherSingleCubitBuilderState();
}

class _SmartRefresherSingleCubitBuilderState extends State<_SmartRefresherSingleCubitBuilder> {
  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    widget.singleCubit.fetch();
    _refreshController = RefreshController(
      initialRefreshStatus: _getRefreshStatus(widget.singleCubit.state),
    );
  }

  @override
  void didUpdateWidget(covariant _SmartRefresherSingleCubitBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.singleCubit != oldWidget.singleCubit) {
      widget.singleCubit.fetch();
    }
  }

  void updateStatus(ObjectCubitState<Object, Object> state) {
    _refreshController.headerMode.value = _getRefreshStatus(state);
  }

  RefreshStatus _getRefreshStatus(ObjectCubitState<Object, Object> state) {
    if (state is ObjectCubitUpdating<Object, Object>) {
      return RefreshStatus.refreshing;
    } else {
      return RefreshStatus.completed;
    }
  }

  void refresh() {
    widget.singleCubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SingleCubit<Object, Object, Object>, ObjectCubitState<Object, Object>>(
      cubit: widget.singleCubit,
      listener: (context, state) => updateStatus(state),
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: widget.isEnabledPullDown,
        enablePullUp: widget.isEnabledPullUp,
        onRefresh: refresh,
        onLoading: null,
        child: widget.child,
      ),
    );
  }
}

class _SmartRefresherMultiCubitBuilder extends SmartRefresherCubitBuilder {
  final MultiCubit<Object, Object, Object> multiCubit;
  final int valuesPerScroll;

  const _SmartRefresherMultiCubitBuilder({
    Key key,
    @required this.multiCubit,
    this.valuesPerScroll = 50,
    bool isEnabledPullDown = true,
    bool isEnabledPullUp = false,
    @required Widget child,
  }) : super._(
          key: key,
          isEnabledPullDown: isEnabledPullDown,
          isEnabledPullUp: isEnabledPullUp,
          child: child,
        );
  @override
  _SmartRefresherMultiCubitBuilderState createState() => _SmartRefresherMultiCubitBuilderState();
}

class _SmartRefresherMultiCubitBuilderState extends State<_SmartRefresherMultiCubitBuilder> {
  RefreshController _refreshController;

  IterableSection _section;

  @override
  void initState() {
    super.initState();
    init();
    _refreshController = RefreshController(
      initialRefreshStatus: _getRefreshStatus(widget.multiCubit.state),
      initialLoadStatus: _getLoadStatus(widget.multiCubit.state),
    );
  }

  @override
  void didUpdateWidget(covariant _SmartRefresherMultiCubitBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.multiCubit != oldWidget.multiCubit) {
      init();
    }
  }

  /// Update section to first section and fetch it
  void init() {
    _section = IterableSection(0, widget.valuesPerScroll);
    widget.multiCubit.fetch(section: _section);
  }

  void updateSmartRefresherController(IterableCubitState<Object, Object> state) {
    _refreshController.headerMode.value = _getRefreshStatus(state);
    _refreshController.footerMode.value = _getLoadStatus(state);
  }

  RefreshStatus _getRefreshStatus(IterableCubitState<Object, Object> state) {
    if (state is IterableCubitUpdating<Object, Object>) {
      return RefreshStatus.refreshing;
    } else {
      return RefreshStatus.completed;
    }
  }

  LoadStatus _getLoadStatus(IterableCubitState<Object, Object> state) {
    if (state.length != null && _section.endAt >= state.length) {
      return LoadStatus.noMore;
    } else if (!state.containsSection(_section)) {
      return LoadStatus.loading;
    } else if (state.containsSection(_section)) {
      return LoadStatus.idle;
    }
    throw 'Not support LoadStatus for $state';
  }

  void loadNextPage() {
    _section = _section.moveOf(widget.valuesPerScroll);
    widget.multiCubit.fetch(section: _section);
  }

  void refresh() {
    widget.multiCubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiCubit<Object, Object, Object>, IterableCubitState<Object, Object>>(
      cubit: widget.multiCubit,
      listener: (context, state) {
        if (state is IterableCubitUpdating<Object, Object>) {
          init();
        }
        updateSmartRefresherController(state);
      },
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: widget.isEnabledPullDown,
        enablePullUp: widget.isEnabledPullUp,
        onRefresh: refresh,
        onLoading: loadNextPage,
        child: widget.child,
      ),
    );
  }
}
