part of '../value/ValueCubit.dart';

abstract class SingleValueCubit<V, Filter extends Object>
    extends ValueCubit<SingleValueState<V, Filter>, Filter> {
  SingleValueCubit({
    bool isLoading = false,
    bool isFetching = true,
    V initialValue,
    Filter initialFilter,
  }) : super(
          IdleSingleValueState(SingleValueStateDelegate<V, Filter>((b) => b
            ..clearAfterFetch = false
            ..value = initialValue
            ..filter = initialFilter)),
          isLoading,
          isFetching,
          initialFilter,
        );

  /// Override this method for fetching value
  /// Call [emitFetched] when fetching is completed
  void onFetching();

  /// Call this method when fetching is completed
  void emitFetched(V value) async {
    await Future.delayed(Duration.zero);
    if (!(state is FetchingValueState<Filter> || state is FetchedValueState<Filter>)) {
      ValueCubitObserver.instance
          .methodIgnored(state, 'emitSuccessFetched(value:$value)');
      return;
    }
    emit(state.toFetched(value));
  }

  /// This method call the onFetching user method
  /// The call of this method is ignored if the fetchStatus is fetching or fetched
  void fetch() async {
    await Future.delayed(Duration.zero);
    if (!state.canFetch) {
      ValueCubitObserver.instance.methodIgnored(state, 'fetch()');
      return;
    }
    emit(state.toFetching());
    onFetching();
  }

  @override
  void _onFetching() => onFetching();
}
