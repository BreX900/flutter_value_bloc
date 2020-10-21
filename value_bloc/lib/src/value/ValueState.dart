part of 'ValueCubit.dart';

abstract class ValueState<Filter> extends Equatable {
  ValueStateDelegate<Filter> get _delegate;

  /// you can use it for filter value/s
  Filter get filter => _delegate.filter;

  /// this method verifies if the bloc is initialized
  bool get isInitialized =>
      _delegate.clearAfterFetch || this is FetchedValueState<Filter>;

  /// return null if the bloc is not initialized else check have value/s
  bool get isEmpty => throw UnimplementedError();

  /// return null if the bloc is not initialized else check have all value/s
  bool get isFully => throw UnimplementedError();

  /// this method verifies that you can call [ValueCubit.load] method
  bool get canLoad => this is IdleValueState<Filter>;

  /// this method verifies that you can call [ValueCubit.fetch] method
  bool get canFetch =>
      (this is LoadedValueState<Filter> || this is FetchedValueState<Filter>) &&
      (isEmpty != true && isFully != true);

  /// this method verifies that you can call [ValueCubit.refresh] method
  bool get canRefresh => isInitialized;

  @mustCallSuper
  ValueState<Filter> _toCopy(void Function(ValueStateDelegateBuilder b) updates);

  @visibleForTesting
  IdleValueState<Filter> toIdle({Filter filter});

  @visibleForTesting
  LoadingValueState<Filter> toLoading({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  });

  @visibleForTesting
  LoadedValueState<Filter> toLoaded();

  @visibleForTesting
  LoadFailedValueState<Filter> toLoadFailed({Object error});

  @visibleForTesting
  FetchingValueState<Filter> toFetching({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  });

  @visibleForTesting
  FetchFailedValueState<Filter> toFetchFailed({Object error});

  @override
  List<Object> get props => [_delegate];

  @override
  bool get stringify => true;
}

abstract class FailedValueState<Filter> extends ValueState<Filter> {
  Object get error;

  @override
  List<Object> get props => super.props..add(error);
}

abstract class ProcessingValueState<Filter> extends ValueState<Filter> {
  /// 1.00 >= progress >= 0.00
  double get progress;

  @override
  List<Object> get props => super.props..add(progress);
}

abstract class IdleValueState<Filter> extends ValueState<Filter> {}

// ---------- Load ----------

abstract class LoadingValueState<Filter> implements ProcessingValueState<Filter> {}

abstract class LoadedValueState<Filter> implements ValueState<Filter> {}

abstract class LoadFailedValueState<Filter> implements FailedValueState<Filter> {}

// ---------- FETCH ----------

abstract class FetchingValueState<Filter> implements ProcessingValueState<Filter> {}

abstract class FetchFailedValueState<Filter> implements FailedValueState<Filter> {}

abstract class FetchedValueState<Filter> implements ValueState<Filter> {}
