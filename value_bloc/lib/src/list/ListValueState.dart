part of '../../value_bloc.dart';

abstract class ListValueState<V, Filter> extends ValueState<Filter> {
  final ListValueStateDelegate<V, Filter> _delegate;

  ListValueState(this._delegate);

  int get countValues => _delegate.countValues;

  BuiltList<V> get values => _delegate.values;

  @override
  bool get isEmpty => this is SuccessFetchedSingleValueState<V, Filter>
      ? values.isEmpty
      : (values.isNotEmpty ? false : null);

  @override
  bool get isFully => this is SuccessFetchedSingleValueState<V, Filter>
      ? values.isNotEmpty
      : (values.isNotEmpty ? true : null);

  @override
  LoadingValueState<Filter> toLoading({Filter filter, double progress = 0.0}) {
    return LoadingListValueState<V, Filter>(_delegate.rebuild((b) => b..filter = filter),
        progress: progress);
  }

  @override
  SuccessLoadedValueState<Filter> toSuccessLoaded() {
    return SuccessLoadedListValueState(_delegate);
  }

  @override
  FailureLoadedValueState<Filter> toFailureLoaded({Object error}) {
    return FailureLoadedListValueState(_delegate, error: error);
  }

  @override
  FetchingValueState<Filter> toFetching({Filter filter, double progress = 0.0}) {
    return FetchingListValueState(_delegate.rebuild((b) => b..filter = filter),
        progress: progress);
  }

  SuccessFetchedListValueState<V, Filter> toSuccessFetched({
    @required FetchScheme scheme,
    @required Iterable<V> values,
    int countValues,
    bool requiredClear = false,
  }) {
    return SuccessFetchedListValueState(
        _delegate.rebuild((b) => (requiredClear ? (b..pages.clear()) : b)
          ..pages[scheme] = values.toBuiltList()
          ..countValues = countValues));
  }

  @override
  FailureFetchedValueState<Filter> toFailureFetched({Object error}) {
    return FailureFetchedListValueState(_delegate, error: error);
  }
}

class LoadingListValueState<V, Filter> extends ListValueState<V, Filter>
    implements LoadingValueState<Filter> {
  final double progress;

  LoadingListValueState(ListValueStateDelegate<V, Filter> delegate, {this.progress = 0.0})
      : super(delegate);

  @override
  List<Object> get props => super.props..add(progress);
}

class SuccessLoadedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements SuccessLoadedValueState<Filter> {
  SuccessLoadedListValueState(ListValueStateDelegate<V, Filter> delegate)
      : super(delegate);
}

class FailureLoadedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements FailureLoadedValueState<Filter> {
  final Object error;

  FailureLoadedListValueState(ListValueStateDelegate<V, Filter> delegate,
      {@required this.error})
      : super(delegate);

  @override
  List<Object> get props => super.props..add(error);
}

class FetchingListValueState<V, Filter> extends ListValueState<V, Filter>
    implements FetchingValueState<Filter> {
  final double progress;

  FetchingListValueState(ListValueStateDelegate<V, Filter> delegate,
      {this.progress = 0.0})
      : super(delegate);
}

class SuccessFetchedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements SuccessFetchedValueState<Filter> {
  SuccessFetchedListValueState(ListValueStateDelegate<V, Filter> delegate)
      : super(delegate);
}

class FailureFetchedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements FailureFetchedValueState<Filter> {
  final Object error;

  FailureFetchedListValueState(ListValueStateDelegate<V, Filter> delegate,
      {@required this.error})
      : super(delegate);

  @override
  List<Object> get props => super.props..add(error);
}
