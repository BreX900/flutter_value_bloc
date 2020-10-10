part of '../../value_bloc.dart';

/// if loadingStatus is loading automatic start loading
/// if fetchStatus is fetching automatic start fetching
abstract class _BaseBloc<S extends BaseBlocState<Filter>, Filter> extends Cubit<S> {
  _BaseBloc(S state) : super(state) {
    if (state.loadStatus == LoadStatusValueBloc.loading) {
      onLoading();
    } else if (state.fetchStatus == FetchStatusValueBloc.fetching) {
      _callOnInitialFetching();
    }
  }

  /// You can override this method for load bloc
  /// You can call [emitLoaded] when loading is completed
  void onLoading() {}

  /// You can call this method when loading is completed
  void emitLoaded() async {
    await Future.delayed(Duration.zero);
    emit(state.rebuild((b) => b.loadStatus = LoadStatusValueBloc.loaded));
    // When is required fetching start fetching
    if (state.fetchStatus.isFetching) _callOnInitialFetching();
  }

  /// This method is used for call the onLoading user method
  /// The call of this method is ignored if the loadStatus is loading or loaded
  void load() async {
    assert(!(state.loadStatus.isLoading || state.loadStatus.isLoaded));
    await Future.delayed(Duration.zero);
    emit(state.rebuild((b) => b.loadStatus = LoadStatusValueBloc.loading));
    onLoading();
  }

  void _callOnInitialFetching();

  void _fetchHandler(void Function() onFetching) async {
    await Future.delayed(Duration.zero);
    emit(state.rebuild((b) => b.fetchStatus = FetchStatusValueBloc.fetching));
    // Call load if required loading or wait completed loading
    if (state.loadStatus.isIdle) {
      load();
    } else if (state.loadStatus.isLoaded) {
      onFetching();
    }
  }

  /// This method is used for recall [onFetch] with new values and [onLoad]
  /// Call this method when the bloc is already loaded and fetched
  void refresh({
    LoadStatusValueBloc loadStatus = LoadStatusValueBloc.loaded,
    bool isInstantRefresh = true,
  }) async {
    assert(state.loadStatus.isLoaded && state.fetchStatus.isFetched);
    await Future.delayed(Duration.zero);

    emit(state.rebuild((b) => b
      ..loadStatus = loadStatus
      ..fetchStatus =
          isInstantRefresh ? FetchStatusValueBloc.fetching : FetchStatusValueBloc.idle
      ..refreshStatus = true));
    if (state.loadStatus.isLoading) {
      onLoading();
    } else if (state.fetchStatus.isFetching) {
      _callOnInitialFetching();
    }
  }

  /// This method is used for update filter and recall [onFetch] with new values and [onLoad]
  /// Call this method when the bloc is not processing load and fetch
  void updateFilter({
    @required Filter filter,
    LoadStatusValueBloc loadStatus = LoadStatusValueBloc.loaded,
    FetchStatusValueBloc fetchStatus = FetchStatusValueBloc.fetching,
  }) async {
    assert(!(state.loadStatus.isLoading && state.fetchStatus.isFetching));
    await Future.delayed(Duration.zero);

    emit(state.rebuild((b) => b
      ..loadStatus = loadStatus
      ..fetchStatus = fetchStatus
      ..refreshStatus = true
      ..filter = filter));
    if (state.loadStatus.isLoading) {
      onLoading();
    } else if (state.fetchStatus.isFetching) {
      _callOnInitialFetching();
    }
  }
}
