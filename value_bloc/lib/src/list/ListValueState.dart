part of '../../value_bloc.dart';

abstract class ListValueState<V, Filter> extends ValueState<Filter> {
  final ListValueStateDelegate<V, Filter> _delegate;

  ListValueState(this._delegate);

  /// it is total possible value fetching
  int get countValues => _delegate.countValues;

  /// results of fetches
  BuiltList<V> get values => _delegate.values;

  /// it contains values
  @override
  bool get isEmpty => isInitialized ? countValues == 0 : null;

  /// is possible fetch more values
  @override
  bool get isFully => isInitialized ? countValues == values.length : null;

  @visibleForTesting
  @override
  IdleValueState<Filter> toIdle({bool clearAfterFetch, Filter filter}) {
    return IdleListValueState(_delegate.rebuild((b) => b
      ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
      ..filter = filter
      ..countValues = null
      ..pages.clear()));
  }

  @visibleForTesting
  @override
  LoadingValueState<Filter> toLoading({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  }) {
    return LoadingListValueState<V, Filter>(
        _delegate.rebuild((b) => b
          ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
          ..filter = filter),
        progress: progress);
  }

  @visibleForTesting
  @override
  LoadedValueState<Filter> toLoaded() {
    return LoadedListValueState(_delegate);
  }

  @visibleForTesting
  @override
  LoadFailedValueState<Filter> toLoadFailed({Object error}) {
    return LoadFailedListValueState(_delegate, error: error);
  }

  @visibleForTesting
  @override
  FetchingListValueState<V, Filter> toFetching({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  }) {
    return FetchingListValueState(
        _delegate.rebuild((b) => b
          ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
          ..filter = filter),
        progress: progress);
  }

  @visibleForTesting
  FetchedListValueState<V, Filter> toSuccessFetched({
    @required FetchScheme scheme,
    @required Iterable<V> values,
    int countValues,
  }) {
    return FetchedListValueState(
        _delegate.rebuild((b) => (b.clearAfterFetch ? (b..pages.clear()) : b)
          ..clearAfterFetch = false
          ..pages[scheme] = values.toBuiltList()
          ..countValues = countValues));
  }
  @visibleForTesting
  @override
  FetchFailedValueState<Filter> toFetchFailed({Object error}) {
    return FetchFailedListValueState(_delegate, error: error);
  }
}

class IdleListValueState<V, Filter> extends ListValueState<V, Filter>
    implements IdleValueState<Filter> {

  IdleListValueState(ListValueStateDelegate<V, Filter> delegate) : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return IdleListValueState(_delegate.rebuild(updates));
  }
}

class LoadingListValueState<V, Filter> extends ListValueState<V, Filter>
    implements LoadingValueState<Filter> {
  final double progress;

  LoadingListValueState(ListValueStateDelegate<V, Filter> delegate, {this.progress = 0.0})
      : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return LoadingListValueState(_delegate.rebuild(updates), progress: progress);
  }
}

class LoadedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements LoadedValueState<Filter> {

  LoadedListValueState(ListValueStateDelegate<V, Filter> delegate)
      : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return LoadedListValueState(_delegate.rebuild(updates));
  }
}

class LoadFailedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements LoadFailedValueState<Filter> {
  final Object error;

  LoadFailedListValueState(ListValueStateDelegate<V, Filter> delegate,
      {@required this.error})
      : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return LoadFailedListValueState(_delegate.rebuild(updates), error: error);
  }
}

class FetchingListValueState<V, Filter> extends ListValueState<V, Filter>
    implements FetchingValueState<Filter> {
  final double progress;

  FetchingListValueState(ListValueStateDelegate<V, Filter> delegate,
      {this.progress = 0.0})
      : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return FetchingListValueState(_delegate.rebuild(updates), progress: progress);
  }
}

class FetchedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements FetchedValueState<Filter> {
  FetchedListValueState(ListValueStateDelegate<V, Filter> delegate)
      : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return FetchedListValueState(_delegate.rebuild(updates));
  }
}

class FetchFailedListValueState<V, Filter> extends ListValueState<V, Filter>
    implements FetchFailedValueState<Filter> {
  final Object error;

  FetchFailedListValueState(ListValueStateDelegate<V, Filter> delegate,
      {@required this.error})
      : super(delegate);

  @override
  ListValueState<V, Filter> _toCopy(_ListCopier updates) {
    return FetchFailedListValueState(_delegate.rebuild(updates), error: error);
  }
}

typedef _ListCopier = void Function(ListValueStateDelegateBuilder b);