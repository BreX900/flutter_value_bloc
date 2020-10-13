part of '../../value_bloc.dart';

abstract class ValueState<Filter> extends Equatable {
  ValueStateDelegate<Filter> get _delegate;

  Filter get filter => _delegate.filter;

  /// return null if the bloc is not initialized else check have value/s
  bool get isEmpty => throw UnimplementedError();

  /// return null if the bloc is not initialized else check have all value/s
  bool get isFully => throw UnimplementedError();

  IdleValueState<Filter> toIdle({Filter filter});

  LoadingValueState<Filter> toLoading({Filter filter, double progress = 0.0});

  SuccessLoadedValueState<Filter> toSuccessLoaded();

  FailureLoadedValueState<Filter> toFailureLoaded({Object error});

  FetchingValueState<Filter> toFetching({Filter filter, double progress = 0.0});

  FailureFetchedValueState<Filter> toFailureFetched({Object error});

  @override
  List<Object> get props => [_delegate];

  @override
  bool get stringify => true;
}

abstract class IdleValueState<Filter> extends ValueState<Filter> {}

abstract class FailureValueState<Filter> extends ValueState<Filter> {
  Object get error;

  @override
  List<Object> get props => super.props..add(error);
}

abstract class ProcessingValueState<Filter> extends ValueState<Filter> {
  double get progress;

  @override
  List<Object> get props => super.props..add(progress);
}

abstract class LoadingValueState<Filter> implements ProcessingValueState<Filter> {}

abstract class SuccessLoadedValueState<Filter> implements ValueState<Filter> {}

abstract class FailureLoadedValueState<Filter> implements FailureValueState<Filter> {}

abstract class FetchingValueState<Filter> implements ProcessingValueState<Filter> {}

abstract class FailureFetchedValueState<Filter> implements FailureValueState<Filter> {}

abstract class SuccessFetchedValueState<Filter> implements ValueState<Filter> {}
