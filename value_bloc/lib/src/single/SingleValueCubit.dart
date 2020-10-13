part of '../../value_bloc.dart';

abstract class SingleValueCubit<V, Filter extends Object>
    extends ValueCubit<SingleValueState<V, Filter>, Filter> {
  SingleValueCubit({
    bool isLoading = false,
    bool isFetching = true,
    V initialValue,
    Filter initialFilter,
  }) : super(
          IdleSingleValueState(SingleValueStateDelegate<V, Filter>((b) => b
            ..value = initialValue
            ..filter = initialFilter)),
          isLoading,
          isFetching,
          initialFilter,
        );

  /// Override this method for fetching value
  /// Call [emitSuccessFetched] when fetching is completed
  void onFetching();

  /// Call this method when fetching is completed
  void emitSuccessFetched(V value) async {
    await Future.delayed(Duration.zero);
    emit(state.toSuccessFetched(value));
  }

  /// This method call the onFetching user method
  /// The call of this method is ignored if the fetchStatus is fetching or fetched
  void fetch() {
    _fetchHandler(() => onFetching());
  }

  @override
  void _callOnInitialFetching() => onFetching();
}
