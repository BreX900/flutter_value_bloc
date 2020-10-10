part of '../../value_bloc.dart';

abstract class ListBloc<V, Filter extends Object>
    extends _BaseBloc<ListBlocState<V, Filter>, Filter> {
  ListBloc({
    LoadStatusValueBloc initialLoadStatus = LoadStatusValueBloc.loaded,
    FetchStatusValueBloc initialFetchStatus = FetchStatusValueBloc.fetching,
  }) : super(ListBlocState<V, Filter>((b) => b
          ..loadStatus = initialLoadStatus
          ..fetchStatus = initialFetchStatus
          ..refreshStatus = false
          ..values));

  /// Override this method for page fetch
  /// You can call [emitFetched] when fetching is completed
  void onFetching(int offset, [int limit]);

  /// Call this method when fetching is completed
  /// Please pass the [offset] and [limit] param from [onFetching]
  void emitFetched(int offset, int limit, Iterable<V> page) {
    emitFetchedCount(offset, limit, page, page.isEmpty ? state.values.length : null);
  }

  /// Call this method when fetching is completed
  /// Please pass the [offset] and [limit] param from [onFetching]
  void emitFetchedCount(int offset, int limit, Iterable<V> page, int countValues) async {
    await Future.delayed(Duration.zero);
    final newOffset = (limit ?? 0) - page.length;
    emit(state.rebuild((b) => (b.refreshStatus ? (b..values.clear()) : b)
      ..values.push(offset, page)
      ..fetchStatus =
          newOffset <= 0 ? FetchStatusValueBloc.fetched : FetchStatusValueBloc.fetching
      ..refreshStatus = false
      ..countValues = countValues));
    if (newOffset > 0) onFetching(newOffset, newOffset);
  }

  /// This method call the onFetching user method
  /// The call of this method is ignored if the fetchStatus is fetching or fetched
  /// if the [indexPage] is null this method fetch next page
  void fetch({int offset, int limit}) {
    assert(!(state.fetchStatus.isFetching || (state.values.length == state.countValues)));
    _fetchHandler(() => onFetching(offset ?? state.values.length, limit));
  }

  void _callOnInitialFetching() => onFetching(0);
}
