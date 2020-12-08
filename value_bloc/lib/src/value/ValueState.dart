import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:value_bloc/src/value/ValueStateDelegate.dart';

abstract class ValueState<Filter> extends Equatable {
  final ValueStateDelegate<Filter> _delegate;

  ValueState(this._delegate);

  /// you can use it for filter value/s
  Filter get filter => _delegate.filter;

  /// this method verifies if the bloc is initialized. After first fetch
  bool get isInitialized;

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

  bool get isRefreshing => _delegate.clearAfterFetch;

  @mustCallSuper
  ValueState<Filter> copy(void Function(ValueStateDelegateBuilder b) updates);

  /// Internal method
  IdleValueState<Filter> toIdle({Filter filter});

  /// Internal method
  LoadingValueState<Filter> toLoading({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  });

  /// Internal method
  LoadedValueState<Filter> toLoaded();

  /// Internal method
  LoadFailedValueState<Filter> toLoadFailed({Object error});

  /// Internal method
  FetchingValueState<Filter> toFetching({
    bool clearAfterFetch,
    Filter filter,
    double progress = 0.0,
  });

  /// Internal method
  FetchFailedValueState<Filter> toFetchFailed({Object error});

  @override
  List<Object> get props => [_delegate];

  @override
  bool get stringify => true;
}

mixin FailedValueState<Filter> on ValueState<Filter> {
  Object get error;

  @override
  List<Object> get props => super.props..add(error);
}

mixin ProcessingValueState<Filter> on ValueState<Filter> {
  /// 1.00 >= progress >= 0.00
  double get progress;

  @override
  List<Object> get props => super.props..add(progress);
}

mixin IdleValueState<Filter> on ValueState<Filter> {}

// ---------- Load ----------

mixin LoadingValueState<Filter> on ProcessingValueState<Filter> {}

mixin LoadedValueState<Filter> on ValueState<Filter> {}

mixin LoadFailedValueState<Filter> on FailedValueState<Filter> {}

// ---------- FETCH ----------

mixin FetchingValueState<Filter> on ProcessingValueState<Filter> {}

mixin FetchFailedValueState<Filter> on FailedValueState<Filter> {}

mixin FetchedValueState<Filter> on ValueState<Filter> {}
