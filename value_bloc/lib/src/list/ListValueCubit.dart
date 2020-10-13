part of '../../value_bloc.dart';

abstract class ListValueCubit<V, Filter extends Object>
    extends ValueCubit<ListValueState<V, Filter>, Filter> {
  final ValueFetcher _fetcher;

  ListValueCubit({
    ValueFetcher fetcher,
    bool isLoading = false,
    bool isFetching = true,
    Filter initialFilter,
  })  : _fetcher = fetcher ?? PageFetcher(),
        super(
          IdleListValueState(ListValueStateDelegate<V, Filter>((b) => b
            ..pages
            ..filter = initialFilter)),
          isLoading,
          isFetching,
          initialFilter,
        );

  /// Override this method for page fetch
  /// You can call [emitSuccessFetched] when fetching is completed
  void onFetching(FetchScheme scheme);

  /// Call this method when fetching is completed
  /// Please pass the [offset] and [limit] param from [onFetching]
  void emitSuccessFetched(FetchScheme scheme, Iterable<V> page) {
    emitSuccessFetchedCount(scheme, page, page.isEmpty ? state.values.length : null);
  }

  /// Call this method when fetching is completed
  /// Please pass the [offset] and [limit] param from [onFetching]
  void emitSuccessFetchedCount(
    FetchScheme scheme,
    Iterable<V> values,
    int countValues,
  ) async {
    assert(scheme != null);
    await Future.delayed(Duration.zero);
    _schemes.remove(scheme);
    emit(state.toSuccessFetched(
      scheme: scheme,
      values: values,
      countValues: countValues,
      requiredClear: _requiredClear,
    ));
    _requiredClear = false;
  }

  var _schemes = <FetchScheme>[];

  /// This method call the onFetching user method
  /// The call of this method is ignored if the fetchStatus is fetching or fetched
  /// if the [indexPage] is null this method fetch next page
  void fetch({int offset, int limit}) {
    _fetchHandler(() {
      _schemes = _fetcher.findSchemes(state._delegate.pages, FetchScheme(offset, limit));
      if (_schemes.isEmpty) return;
      _schemes.forEach(onFetching);
    });
  }

  void _callOnInitialFetching() =>
      onFetching(_fetcher.initFetchScheme(state._delegate.pages, FetchScheme(0, null)));

  var _requiredClear = false;

  @override
  void refresh({bool isLoading = false, bool isFetching = true}) {
    _requiredClear = true;
    super.refresh(isLoading: isLoading, isFetching: isFetching);
  }

  @override
  void updateFilter({
    @required Filter filter,
    bool isLoading = false,
    bool isFetching = true,
  }) {
    _requiredClear = true;
    super.updateFilter(filter: filter, isLoading: isLoading, isFetching: isFetching);
  }
}
