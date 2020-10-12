part of '../../value_bloc.dart';

abstract class SingleValueState<V, Filter> extends ValueState<Filter> {
  final SingleValueStateDelegate<V, Filter> _delegate;

  SingleValueState(this._delegate);

  V get value => _delegate.value;

  @override
  bool get isEmpty => this is SuccessFetchedSingleValueState<V, Filter>
      ? value == null
      : (value != null ? false : null);

  @override
  bool get isFully => this is SuccessFetchedSingleValueState<V, Filter>
      ? value != null
      : (value != null ? true : null);

  @override
  LoadingValueState<Filter> toLoading({Filter filter, double progress = 0.0}) {
    return LoadingSingleValueState<V, Filter>(
        _delegate.rebuild((b) => b..filter = filter),
        progress: progress);
  }

  @override
  SuccessLoadedValueState<Filter> toSuccessLoaded() {
    return SuccessLoadedSingleValueState(_delegate);
  }

  @override
  FailureLoadedValueState<Filter> toFailureLoaded({Object error}) {
    return FailureLoadedSingleValueState(_delegate, error: error);
  }

  @override
  FetchingValueState<Filter> toFetching({Filter filter, double progress = 0.0}) {
    return FetchingSingleValueState(_delegate.rebuild((b) => b..filter = filter),
        progress: progress);
  }

  SuccessFetchedSingleValueState<V, Filter> toSuccessFetched(V value) {
    return SuccessFetchedSingleValueState(_delegate.rebuild((b) => b..value = value));
  }

  @override
  FailureFetchedValueState<Filter> toFailureFetched({Object error}) {
    return FailureFetchedSingleValueState(_delegate, error: error);
  }
}

class LoadingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements LoadingValueState<Filter> {
  final double progress;

  LoadingSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
      {this.progress = 0.0})
      : super(delegate);

  @override
  List<Object> get props => super.props..add(progress);
}

class SuccessLoadedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements SuccessLoadedValueState<Filter> {
  SuccessLoadedSingleValueState(SingleValueStateDelegate<V, Filter> delegate)
      : super(delegate);
}

class FailureLoadedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements FailureLoadedValueState<Filter> {
  final Object error;

  FailureLoadedSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
      {@required this.error})
      : super(delegate);
}

class FetchingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements FetchingValueState<Filter> {
  final double progress;

  FetchingSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
      {this.progress = 0.0})
      : super(delegate);
}

class SuccessFetchedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements SuccessFetchedValueState<Filter> {
  SuccessFetchedSingleValueState(SingleValueStateDelegate<V, Filter> delegate)
      : super(delegate);
}

class FailureFetchedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements FailureFetchedValueState<Filter> {
  final Object error;

  FailureFetchedSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
      {@required this.error})
      : super(delegate);
}

// class FailureRefreshingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     implements FailureFetchedValueState<Filter> {
//   final Object error;
//
//   FailureRefreshingSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
//       {@required this.error})
//       : super(delegate);
//
//   @override
//   List<Object> get props => super.props..add(error);
// }
