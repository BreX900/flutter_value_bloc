part of '../../value_bloc.dart';

/// if loadingStatus is loading automatic start loading
/// if fetchStatus is fetching automatic start fetching
abstract class ValueCubit<S extends ValueState<Filter>, Filter> extends Cubit<S> {
  bool _fetchAfterLoad;

  ValueCubit(S state, bool isLoading, bool isFetching, Filter initialFilter)
      : super(_resolveState(state, isLoading, isFetching, filter: initialFilter)) {
    _resolve(isLoading, isFetching);
  }

  /// You can override this method for load bloc
  /// You can call [emitSuccessLoaded] when loading is completed
  void onLoading() {}

  void emitLoading({@required double progress}) {
    emit(state.toLoading(progress: progress) as S);
  }

  /// You can call this method when loading is completed
  void emitSuccessLoaded() async {
    await Future.delayed(Duration.zero);
    emit(state.toSuccessLoaded() as S);
    // When is required fetching start fetching
    if (!_fetchAfterLoad) return;
    fetch();
  }

  void emitFailureLoaded({Object error}) async {
    await Future.delayed(Duration.zero);
    emit(state.toFailureLoaded(error: error) as S);
  }

  void emitFetching({double progress}) async {
    await Future.delayed(Duration.zero);
    emit(state.toFetching(progress: progress) as S);
  }

  void emitFailureFetched({Object error}) async {
    await Future.delayed(Duration.zero);
    emit(state.toFailureFetched(error: error) as S);
  }

  /// This method is used for call the onLoading user method
  /// The call of this method is ignored if the loadStatus is loading or loaded
  void load() async {
    await Future.delayed(Duration.zero);
    assert(!(state is LoadingValueState<Filter>));
    emit(state.toLoading() as S);
    onLoading();
  }

  void fetch();

  /// This method is used for recall [onFetch] with new values and [onLoad]
  /// Call this method when the bloc is already loaded and fetched
  void refresh({
    bool isLoading = false,
    bool isFetching = true,
  }) async {
    await Future.delayed(Duration.zero);
    _resolveCurrentState(isLoading, isFetching);
  }

  /// This method is used for update filter and recall [onFetch] with new values and [onLoad]
  /// Call this method when the bloc is not processing load and fetch
  void updateFilter({
    @required Filter filter,
    bool isLoading = false,
    bool isFetching = true,
  }) async {
    await Future.delayed(Duration.zero);
    _resolveCurrentState(isLoading, isFetching, filter: filter);
  }

  void clear({bool isLoading, bool isFetching}) async {
    await Future.delayed(Duration.zero);
    _resolveCurrentState(isLoading, isFetching);
  }

  void _resolve(bool isLoading, bool isFetching) {
    _fetchAfterLoad = isLoading && isFetching;
    if (isLoading) {
      onLoading();
    } else if (isFetching) {
      _callOnInitialFetching();
    }
  }

  void _resolveCurrentState(bool isLoading, bool isFetching, {Filter filter}) {
    emit(_resolveState<Filter>(state, isLoading, isFetching, filter: filter) as S);
    _resolve(isLoading, true);
  }

  static ValueState<Filter> _resolveState<Filter>(
    ValueState<Filter> state,
    bool isLoading,
    bool isFetching, {
    Filter filter,
  }) {
    if (isLoading) {
      return state.toLoading(filter: filter);
    } else if (isFetching) {
      return state.toFetching(filter: filter);
    } else {
      return state.toIdle(filter: filter);
    }
  }

  void _callOnInitialFetching();

  Future<void> _fetchHandler(void Function() onFetching) async {
    await Future.delayed(Duration.zero);
    assert(!(state is LoadingValueState || state is FetchingValueState));
    emit(state.toFetching() as S);
    onFetching();
  }
}
