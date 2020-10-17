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
            ..clearAfterFetch = false
            ..pages
            ..filter = initialFilter)),
          isLoading,
          isFetching,
          initialFilter,
        );

  /// Override this method for page fetch
  /// You can call [emitFetched] when fetching is completed
  void onFetching(FetchScheme scheme);

  /// Call this method when fetching is completed
  /// Please pass the [offset] and [limit] param from [onFetching]
  void emitFetched(FetchScheme scheme, Iterable<V> page) {
    emitFetchedCount(scheme, page, page.isEmpty ? state.values.length : null);
  }

  /// Call this method when fetching is completed
  /// Please pass the [offset] and [limit] param from [onFetching]
  void emitFetchedCount(FetchScheme scheme, Iterable<V> values, int countValues) async {
    assert(scheme != null && values != null, 'scheme:$scheme,values:$values');
    await Future.delayed(Duration.zero);
    if (!(state is FetchingValueState<Filter> || state is FetchedValueState<Filter>)) {
      ValueCubitObserver.instance.methodIgnored(state,
          'emitFetchedCount(scheme:$scheme,values$values,countValues:$countValues)');
      return;
    }
    // Todo: move this logic in Fetcher class
    // ignore update if the scheme is old
    if (!_schemes.contains(scheme)) {
      ValueCubitObserver.instance.methodIgnored(state,
          'emitFetchedCount(scheme:$scheme,values$values,countValues:$countValues)');
      return;
    }
    emit(state.toSuccessFetched(
      scheme: scheme,
      values: values,
      countValues: countValues,
    ));
  }

  var _schemes = <FetchScheme>[];

  /// This method call the onFetching user method
  /// The call of this method is ignored if the fetchStatus is fetching or fetched
  /// if the [indexPage] is null this method fetch next page
  void fetch({int offset, int limit}) async {
    await Future.delayed(Duration.zero);
    if (state.canFetch) {
      ValueCubitObserver.instance
          .methodIgnored(state, 'fetch(offset:$offset,limit:$limit)');
      return;
    }
    final newSchemes =
        _fetcher.findSchemes(state._delegate.pages, FetchScheme(offset, limit));
    _schemes.addAll(newSchemes);
    if (newSchemes.isEmpty) {
      ValueCubitObserver.instance
          .methodIgnored(state, 'fetch(offset:$offset,limit:$limit)');
      return;
    }
    emit(state.toFetching());
    newSchemes.forEach(onFetching);
  }

  void _onFetching() =>
      onFetching(_fetcher.initFetchScheme(state._delegate.pages, FetchScheme(0, null)));
}
