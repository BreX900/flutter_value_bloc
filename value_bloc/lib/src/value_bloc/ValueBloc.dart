part of '../../value_bloc.dart';

abstract class ValueBloc<V, Filter extends Object>
    extends _BaseBloc<ValueBlocState<V, Filter>, Filter> {
  ValueBloc({
    LoadStatusValueBloc initialLoadStatus = LoadStatusValueBloc.loaded,
    FetchStatusValueBloc initialFetchStatus = FetchStatusValueBloc.fetching,
    V initialValue,
    Filter initialFilter,
  })  : assert(initialLoadStatus != null),
        assert(initialFetchStatus != null),
        super(ValueBlocState((b) => b
          ..loadStatus = initialLoadStatus
          ..fetchStatus = initialFetchStatus
          ..refreshStatus = false
          ..value = initialValue
          ..filter = initialFilter));

  /// Override this method for fetching value
  /// Call [emitFetched] when fetching is completed
  void onFetching();

  /// Call this method when fetching is completed
  void emitFetched(V value) async {
    await Future.delayed(Duration.zero);
    emit(state.rebuild((b) => b
      ..fetchStatus = FetchStatusValueBloc.fetched
      ..refreshStatus = false
      ..value = value));
  }

  /// This method call the onFetching user method
  /// The call of this method is ignored if the fetchStatus is fetching or fetched
  void fetch() {
    assert(!(state.fetchStatus.isFetching || state.fetchStatus.isFetched));
    _fetchHandler(() => onFetching());
  }

  @override
  void _callOnInitialFetching() => onFetching();
}
