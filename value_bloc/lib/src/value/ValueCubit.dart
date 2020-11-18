import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:value_bloc/src/ValueCubitObserver.dart';

import 'ValueState.dart';

/// if loadingStatus is loading automatic start loading
/// if fetchStatus is fetching automatic start fetching
abstract class ValueCubit<S extends ValueState<Filter>, Filter> extends Cubit<S> {
  bool _fetchAfterLoad;

  ValueCubit(S state, bool isLoading, bool isFetching, Filter initialFilter)
      : super(_resolveState(state, isLoading, isFetching, filter: initialFilter)) {
    _fetchAfterLoad = isLoading && isFetching;
    if (isLoading) {
      emit(state.toLoading() as S);
      onLoading();
    } else if (isFetching) {
      emit(state.toFetching() as S);
      firstFetchingHandle();
    }
  }

  /// You can override this method for load bloc
  /// You can call [emitLoaded] when loading is completed
  void onLoading() {}

  /// You can use it for update loading progress
  /// visit [ProcessingValueState.progress] for [progress] param
  void emitLoading({@required double progress}) async {
    await _wait;
    if (state is LoadingValueState<Filter>) {
      ValueCubitObserver.instance.methodIgnored(state, 'emitLoading(progress:$progress)');
      return;
    }
    emit(state.toLoading(progress: progress) as S);
  }

  /// You can call this method when loading is completed
  void emitLoaded() async {
    await Future.delayed(Duration.zero);
    if (!(state is LoadingValueState<Filter>)) {
      ValueCubitObserver.instance.methodIgnored(state, 'emitLoaded()');
      return;
    }
    emit(state.toLoaded() as S);
    // When is required fetching start fetching
    if (_fetchAfterLoad) fetch();
  }

  /// You can use it when the load returns a error/exception
  void emitLoadFailed({Object error}) async {
    await Future.delayed(Duration.zero);
    if (state is LoadingValueState<Filter>) {
      ValueCubitObserver.instance.methodIgnored(state, 'emitLoadFailed(error:$error)');
      return;
    }
    emit(state.toLoadFailed(error: error) as S);
  }

  /// You can use it for update fetching progress
  /// visit [ProcessingValueState.progress] for [progress] param
  void emitFetching({double progress}) async {
    await Future.delayed(Duration.zero);
    if (!(state is FetchingValueState<Filter>)) {
      ValueCubitObserver.instance.methodIgnored(state, 'emitFetching(progress:$progress)');
      return;
    }
    emit(state.toFetching(progress: progress) as S);
  }

  /// You can use it when the fetch returns a error/exception
  void emitFetchFailed({Object error}) async {
    await Future.delayed(Duration.zero);
    if (!(state is FetchingValueState<Filter> || state is FetchedValueState<Filter>)) {
      ValueCubitObserver.instance.methodIgnored(state, 'emitFailureFetched(error:$error)');
      return;
    }
    emit(state.toFetchFailed(error: error) as S);
  }

  /// It is used for pre load cubit before fetch value/s
  /// It call the [onLoading] user method
  /// You can call [refresh] method for reload cubit
  void load() async {
    await Future.delayed(Duration.zero);
    if (!state.canLoad) {
      ValueCubitObserver.instance.methodIgnored(state, 'load()');
      return;
    }
    emit(state.toLoading() as S);
    onLoading();
  }

  void fetch();

  /// It is used for recall [onFetch] or/and [onLoad]
  /// You can use this method after call [updateFilter] for filter values
  /// Call this method when the bloc is already loaded and fetched
  void refresh({Filter filter, bool isLoading = false}) async {
    await Future.delayed(Duration.zero);
    if (!state.canRefresh) {
      ValueCubitObserver.instance.methodIgnored(state, 'refresh(isLoading:$isLoading)');
      return;
    }
    _fetchAfterLoad = isLoading && true;
    if (isLoading) {
      emit(state.toLoading(clearAfterFetch: true) as S);
      onLoading();
    } else {
      emit(state.toFetching(clearAfterFetch: true) as S);
      firstFetchingHandle();
    }
  }

  /// This method is used for update filter
  void updateFilter({@required Filter filter}) async {
    await Future.delayed(Duration.zero);
    emit(state.copy((b) => b..filter = filter) as S);
  }

  /// This method is used for reset the bloc to idle state
  void clear({Filter filter}) async {
    await Future.delayed(Duration.zero);
    if (state is LoadingValueState<Filter>) {
      ValueCubitObserver.instance.methodIgnored(state, 'clear(filter:$filter)');
      return;
    }
    emit(state.toIdle(filter: filter) as S);
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

  Future<void> _wait = Future.delayed(Duration.zero);

  @protected
  void firstFetchingHandle();
}
