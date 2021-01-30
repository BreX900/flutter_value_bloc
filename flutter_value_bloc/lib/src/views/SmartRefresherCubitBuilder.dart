import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class SmartRefresherCubitBuilder extends StatefulWidget {
  const SmartRefresherCubitBuilder._({Key key}) : super(key: key);

  factory SmartRefresherCubitBuilder.single({
    Key key,
    @required SingleCubit<Object, Object> singleCubit,
  }) = _SmartRefresherSingleCubitBuilder;

  factory SmartRefresherCubitBuilder.multi({
    Key key,
    @required MultiCubit<Object, Object> multiCubit,
    int valuesPerFetch,
  }) = _SmartRefresherMultiCubitBuilder;
}

class _SmartRefresherSingleCubitBuilder extends SmartRefresherCubitBuilder {
  final SingleCubit<Object, Object> singleCubit;

  const _SmartRefresherSingleCubitBuilder({
    Key key,
    @required this.singleCubit,
  }) : super._(key: key);

  @override
  _SmartRefresherSingleCubitBuilderState createState() => _SmartRefresherSingleCubitBuilderState();
}

class _SmartRefresherSingleCubitBuilderState extends State<_SmartRefresherSingleCubitBuilder> {
  RefreshController _refreshController;

  IterableSection section;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(
      initialRefreshStatus: _getRefreshStatus(widget.singleCubit.state),
    );
  }

  void updateStatus(ObjectCubitState<Object, Object> state) {
    _refreshController.headerMode.value = _getRefreshStatus(state);
  }

  RefreshStatus _getRefreshStatus(ObjectCubitState<Object, Object> state) {
    if (state is ObjectCubitIdle<Object, Object>) {
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
    return BlocListener<SingleCubit<Object, Object>, ObjectCubitState<Object, Object>>(
      cubit: widget.singleCubit,
      listener: (context, state) => updateStatus(state),
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: widget.enablePullDown,
        enablePullUp: widget.enablePullUp,
        onRefresh: refresh,
        onLoading: null,
        child: widget.child,
      ),
    );
  }
}

class _SmartRefresherMultiCubitBuilder extends SmartRefresherCubitBuilder {
  final MultiCubit<Object, Object> multiCubit;
  final int valuesPerFetch;

  const _SmartRefresherMultiCubitBuilder({
    Key key,
    @required this.multiCubit,
    this.valuesPerFetch = 10,
  }) : super._(key: key);

  @override
  _SmartRefresherMultiCubitBuilderState createState() => _SmartRefresherMultiCubitBuilderState();
}

class _SmartRefresherMultiCubitBuilderState extends State<_SmartRefresherMultiCubitBuilder> {
  RefreshController _refreshController;

  IterableSection section;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(
      initialRefreshStatus: _getRefreshStatus(widget.multiCubit.state),
      initialLoadStatus: _getLoadStatus(widget.multiCubit.state),
    );
    section = IterableSection(0, widget.valuesPerFetch);
  }

  void updateStatus(IterableCubitState<Object, Object> state) {
    if (state is IterableCubitIdle<Object, Object>) {
      section = IterableSection(0, widget.valuesPerFetch);
      widget.multiCubit.fetch(section: section);
    }

    _refreshController.headerMode.value = _getRefreshStatus(state);
    _refreshController.footerMode.value = _getLoadStatus(state);
  }

  RefreshStatus _getRefreshStatus(IterableCubitState<Object, Object> state) {
    if (state is IterableCubitIdle<Object, Object>) {
      return RefreshStatus.refreshing;
    } else {
      return RefreshStatus.completed;
    }
  }

  LoadStatus _getLoadStatus(IterableCubitState<Object, Object> state) {
    if (state.length != null && section.endAt >= state.length) {
      return LoadStatus.noMore;
    } else if (!state.containsSection(section)) {
      return LoadStatus.loading;
    } else if (state.containsSection(section)) {
      return LoadStatus.idle;
    }
    throw 'Not support LoadStatus for $state';
  }

  void loadNextPage() {
    section = section.moveOf(widget.valuesPerFetch);
    widget.multiCubit.fetch(section: section);
  }

  void refresh() {
    widget.multiCubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiCubit<Object, Object>, IterableCubitState<Object, Object>>(
      cubit: widget.multiCubit,
      listener: (context, state) => updateStatus(state),
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: widget.enablePullDown,
        enablePullUp: widget.enablePullUp,
        onRefresh: refresh,
        onLoading: loadNextPage,
        child: widget.child,
      ),
    );
  }
}
