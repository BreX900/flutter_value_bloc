import 'package:meta/meta.dart';

import '../value/ValueState.dart';
import 'SingleValueStateDelegate.dart';

abstract class SingleValueState<V, Filter> extends ValueState<Filter> {
  final SingleValueStateDelegate<V, Filter> _delegate;

  SingleValueState(this._delegate);

  V get value => _delegate.value;

  @override
  bool get isEmpty => isInitialized ? null : value == null;

  @override
  bool get isFully => isInitialized ? null : value != null;

  /// Internal method
  @override
  IdleValueState<Filter> toIdle({bool clearAfterFetch, Filter filter}) {
    return IdleSingleValueState(_delegate.rebuild((b) => b
      ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
      ..filter = filter
      ..value = null));
  }

  /// Internal method
  @override
  LoadingValueState<Filter> toLoading(
      {bool clearAfterFetch, Filter filter, double progress = 0.0}) {
    return LoadingSingleValueState<V, Filter>(
        _delegate.rebuild((b) => b
          ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
          ..filter = filter),
        progress: progress);
  }

  /// Internal method
  @override
  LoadedValueState<Filter> toLoaded() {
    return SuccessLoadedSingleValueState(_delegate);
  }

  /// Internal method
  @override
  LoadFailedValueState<Filter> toLoadFailed({Object error}) {
    return LoadFailedSingleValueState(_delegate, error: error);
  }

  /// Internal method
  @override
  FetchingSingleValueState<V, Filter> toFetching({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  }) {
    return FetchingSingleValueState(
        _delegate.rebuild((b) => b
          ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
          ..filter = filter),
        progress: progress);
  }

  /// Internal method
  FetchedSingleValueState<V, Filter> toFetched(V value) {
    return FetchedSingleValueState(_delegate.rebuild((b) => b
      ..clearAfterFetch = false
      ..value = value));
  }

  /// Internal method
  @override
  FetchFailedValueState<Filter> toFetchFailed({Object error}) {
    return FetchFailedSingleValueState(_delegate, error: error);
  }
}

class IdleSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements IdleValueState<Filter> {
  IdleSingleValueState(SingleValueStateDelegate<V, Filter> delegate) : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return IdleSingleValueState(_delegate.rebuild(updates));
  }
}

class LoadingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements LoadingValueState<Filter> {
  final double progress;

  LoadingSingleValueState(SingleValueStateDelegate<V, Filter> delegate, {this.progress = 0.0})
      : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return LoadingSingleValueState(_delegate.rebuild(updates), progress: progress);
  }
}

class SuccessLoadedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements LoadedValueState<Filter> {
  SuccessLoadedSingleValueState(SingleValueStateDelegate<V, Filter> delegate) : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return SuccessLoadedSingleValueState(_delegate.rebuild(updates));
  }
}

class LoadFailedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements LoadFailedValueState<Filter> {
  final Object error;

  LoadFailedSingleValueState(SingleValueStateDelegate<V, Filter> delegate, {@required this.error})
      : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return LoadFailedSingleValueState(_delegate.rebuild(updates), error: error);
  }
}

class FetchingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements FetchingValueState<Filter> {
  final double progress;

  FetchingSingleValueState(SingleValueStateDelegate<V, Filter> delegate, {this.progress = 0.0})
      : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return FetchingSingleValueState(_delegate.rebuild(updates), progress: progress);
  }
}

class FetchedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements FetchedValueState<Filter> {
  FetchedSingleValueState(SingleValueStateDelegate<V, Filter> delegate) : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return FetchedSingleValueState(_delegate.rebuild(updates));
  }
}

class FetchFailedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
    implements FetchFailedValueState<Filter> {
  final Object error;

  FetchFailedSingleValueState(SingleValueStateDelegate<V, Filter> delegate, {@required this.error})
      : super(delegate);

  @override
  SingleValueState<V, Filter> copy(_SingleCopier updates) {
    return FetchFailedSingleValueState(_delegate.rebuild(updates), error: error);
  }
}

typedef _SingleCopier = void Function(SingleValueStateDelegateBuilder b);
