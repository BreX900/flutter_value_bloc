import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_bloc/src/value_view/ValueViewBuilder.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as ptr;
import 'package:value_bloc/value_bloc.dart';

/// This is a plugin used in [DynamicCubitBuilder]
/// and it integrate a [RefresherValueCubitBuilder]
class RefresherValueCubitPlugin<C extends ValueCubit<S, Filter>, S extends ValueState<Filter>,
    Filter> extends ViewValueCubitPlugin<C, S, Filter> {
  final bool enablePullDown;
  final bool enablePullUp;

  RefresherValueCubitPlugin({this.enablePullDown = true, this.enablePullUp = false});

  @override
  Widget apply(C valueCubit, S builderState, Widget child) {
    return RefresherValueCubitBuilder(
      valueCubit: valueCubit,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      child: child,
    );
  }
}

/// This is the most important component that provides drop-down refresh and up loading.
/// It implement a [ptr.SmartRefresher] class with [ValueCubit] state logic management
class RefresherValueCubitBuilder extends StatefulWidget {
  final ValueCubit<ValueState<dynamic>, dynamic> valueCubit;
  final bool enablePullDown;
  final bool enablePullUp;
  final Widget child;

  const RefresherValueCubitBuilder({
    Key key,
    @required this.valueCubit,
    this.enablePullDown = true,
    this.enablePullUp = false,
    @required this.child,
  }) : super(key: key);

  @override
  _RefresherValueCubitBuilderState createState() => _RefresherValueCubitBuilderState();
}

class _RefresherValueCubitBuilderState extends State<RefresherValueCubitBuilder> {
  ptr.RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = ptr.RefreshController(
      initialRefreshStatus: _getRefreshStatus(widget.valueCubit.state),
      initialLoadStatus: _getLoadStatus(widget.valueCubit.state),
    );
  }

  @override
  void didUpdateWidget(covariant RefresherValueCubitBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valueCubit != oldWidget.valueCubit) {
      updateStatus(widget.valueCubit.state);
    }
  }

  void updateStatus(ValueState<dynamic> state) {
    _refreshController.headerMode.value = _getRefreshStatus(state);
    _refreshController.footerMode.value = _getLoadStatus(state);
  }

  ptr.RefreshStatus _getRefreshStatus(ValueState state) {
    if (state.isRefreshing) {
      return ptr.RefreshStatus.refreshing;
    } else {
      return ptr.RefreshStatus.completed;
    }
  }

  ptr.LoadStatus _getLoadStatus(ValueState state) {
    assert(state.isFully != null, 'Not support for $state');
    if (!widget.enablePullUp) return ptr.LoadStatus.idle;
    if (state.isFully) {
      return ptr.LoadStatus.noMore;
    } else if (state is FetchingValueState) {
      return ptr.LoadStatus.loading;
    } else if (state is FetchedValueState) {
      return ptr.LoadStatus.idle;
    }
    throw 'Not support LoadStatus for $state';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ValueCubit<ValueState<dynamic>, dynamic>, ValueState<dynamic>>(
      cubit: widget.valueCubit,
      listener: (context, state) => updateStatus(state),
      child: ptr.SmartRefresher(
        controller: _refreshController,
        enablePullDown: widget.enablePullDown,
        enablePullUp: widget.enablePullUp,
        onRefresh: widget.valueCubit.refresh,
        onLoading: widget.valueCubit.fetch,
        child: widget.child,
      ),
    );
  }
}
