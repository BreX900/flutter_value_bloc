part of 'ValueCubit.dart';

abstract class CubitState<Value, Filter, ExtraData> {
  final Filter filter;
  final bool hasValue;
  final Value value;
  final ExtraData extraData;

  CubitState({
    @required this.filter,
    @required this.hasValue,
    @required this.value,
    @required this.extraData,
  }) : assert(hasValue != null);

  CubitState<Value, Filter, ExtraData> toFetchingWithExtraData({
    double progress = 0.0,
    Filter filter,
  }) {
    return ValueCubitFetching(
      filter: filter,
      hasValue: hasValue,
      value: value,
      progress: progress,
      extraData: extraData,
    );
  }

  CubitState<Value, Filter, ExtraData> toFetching({double progress = 0.0}) {
    return ValueCubitFetching(
      filter: filter,
      hasValue: hasValue,
      value: value,
      progress: progress,
      extraData: extraData,
    );
  }

  CubitState<Value, Filter, ExtraData> toFetchFailed({
    bool canFetchAgain = false,
    Object failure,
  }) {
    return ValueCubitFetchFailed(
      filter: filter,
      hasValue: hasValue,
      value: value,
      canFetchAgain: canFetchAgain,
      failure: failure,
      extraData: extraData,
    );
  }

  CubitState<Value, Filter, ExtraData> toFetched({@required bool hasValue, @required Value value}) {
    return ValueCubitFetched(
      filter: filter,
      hasValue: hasValue,
      value: value,
      extraData: extraData,
    );
  }
}

class ValueCubitFetching<Value, Filter, ExtraData> extends CubitState<Value, Filter, ExtraData> {
  final double progress;

  ValueCubitFetching({
    Filter filter,
    @required bool hasValue,
    Value value,
    this.progress = 0.0,
    ExtraData extraData,
  }) : super(
          filter: filter,
          hasValue: hasValue,
          value: value,
          extraData: extraData,
        );
}

class ValueCubitFetchFailed<Value, Filter, ExtraData> extends CubitState<Value, Filter, ExtraData> {
  final bool canFetchAgain;
  final Object failure;

  ValueCubitFetchFailed({
    Filter filter,
    @required bool hasValue,
    Value value,
    @required this.canFetchAgain,
    this.failure,
    ExtraData extraData,
  }) : super(
          filter: filter,
          hasValue: hasValue,
          value: value,
          extraData: extraData,
        );
}

class ValueCubitFetched<Value, Filter, ExtraData> extends CubitState<Value, Filter, ExtraData> {
  ValueCubitFetched({
    Filter filter,
    @required bool hasValue,
    @required Value value,
    ExtraData extraData,
  }) : super(
          filter: filter,
          hasValue: hasValue,
          value: value,
          extraData: extraData,
        );
}

// abstract class SingleValueState<V, Filter> extends ValueState<Filter> {
//   final SingleValueStateDelegate<V, Filter> _delegate;
//
//   SingleValueState(this._delegate) : super(_delegate);
//
//   V get value => _delegate.value;
//
//   @override
//   bool get isInitialized =>
//       _delegate.clearAfterFetch || this is FetchedValueState<Filter>;
//
//   @override
//   bool get isEmpty => isInitialized ? value == null : null;
//
//   @override
//   bool get isFully => isInitialized ? value != null : null;
//
//   /// Internal method
//   @override
//   IdleValueState<Filter> toIdle({bool clearAfterFetch, Filter filter}) {
//     return IdleSingleValueState(_delegate.rebuild((b) => b
//       ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
//       ..filter = filter
//       ..value = null));
//   }
//
//   /// Internal method
//   @override
//   LoadingValueState<Filter> toLoading(
//       {bool clearAfterFetch, Filter filter, double progress = 0.0}) {
//     return LoadingSingleValueState<V, Filter>(
//         _delegate.rebuild((b) => b
//           ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
//           ..filter = filter),
//         progress: progress);
//   }
//
//   /// Internal method
//   @override
//   LoadedValueState<Filter> toLoaded() {
//     return SuccessLoadedSingleValueState(_delegate);
//   }
//
//   /// Internal method
//   @override
//   LoadFailedValueState<Filter> toLoadFailed({Object error}) {
//     return LoadFailedSingleValueState(_delegate, error: error);
//   }
//
//   /// Internal method
//   @override
//   FetchingSingleValueState<V, Filter> toFetching({
//     bool clearAfterFetch,
//     Filter filter,
//     double progress = 0.0,
//   }) {
//     return FetchingSingleValueState(
//         _delegate.rebuild((b) => b
//           ..clearAfterFetch = clearAfterFetch ?? b.clearAfterFetch
//           ..filter = filter),
//         progress: progress);
//   }
//
//   /// Internal method
//   FetchedSingleValueState<V, Filter> toFetched(V value) {
//     return FetchedSingleValueState(_delegate.rebuild((b) => b
//       ..clearAfterFetch = false
//       ..value = value));
//   }
//
//   /// Internal method
//   @override
//   FetchFailedValueState<Filter> toFetchFailed({Object error}) {
//     return FetchFailedSingleValueState(_delegate, error: error);
//   }
// }
//
// mixin FailedSingleValueState<V, Filter>
//     on SingleValueState<V, Filter>, FailedValueState<Filter> {}
//
// mixin ProcessingSingleValueState<V, Filter>
//     on SingleValueState<V, Filter>, ProcessingValueState<Filter> {}
//
// class IdleSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     with IdleValueState<Filter> {
//   IdleSingleValueState(SingleValueStateDelegate<V, Filter> delegate)
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return IdleSingleValueState(_delegate.rebuild(updates));
//   }
// }
//
// class LoadingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     with
//         ProcessingValueState<Filter>,
//         LoadingValueState<Filter>,
//         ProcessingSingleValueState<V, Filter> {
//   @override
//   final double progress;
//
//   LoadingSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
//       {this.progress = 0.0})
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return LoadingSingleValueState(_delegate.rebuild(updates),
//         progress: progress);
//   }
// }
//
// class SuccessLoadedSingleValueState<V, Filter>
//     extends SingleValueState<V, Filter> with LoadedValueState<Filter> {
//   SuccessLoadedSingleValueState(SingleValueStateDelegate<V, Filter> delegate)
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return SuccessLoadedSingleValueState(_delegate.rebuild(updates));
//   }
// }
//
// class LoadFailedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     with
//         FailedValueState,
//         LoadFailedValueState<Filter>,
//         FailedSingleValueState<V, Filter> {
//   @override
//   final Object error;
//
//   LoadFailedSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
//       {@required this.error})
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return LoadFailedSingleValueState(_delegate.rebuild(updates), error: error);
//   }
// }
//
// class FetchingSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     with
//         ProcessingValueState,
//         FetchingValueState<Filter>,
//         ProcessingSingleValueState<V, Filter> {
//   @override
//   final double progress;
//
//   FetchingSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
//       {this.progress = 0.0})
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return FetchingSingleValueState(_delegate.rebuild(updates),
//         progress: progress);
//   }
// }
//
// class FetchedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     with FetchedValueState<Filter> {
//   FetchedSingleValueState(SingleValueStateDelegate<V, Filter> delegate)
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return FetchedSingleValueState(_delegate.rebuild(updates));
//   }
// }
//
// class FetchFailedSingleValueState<V, Filter> extends SingleValueState<V, Filter>
//     with
//         FailedValueState,
//         FetchFailedValueState,
//         FailedSingleValueState<V, Filter> {
//   @override
//   final Object error;
//
//   FetchFailedSingleValueState(SingleValueStateDelegate<V, Filter> delegate,
//       {@required this.error})
//       : super(delegate);
//
//   @override
//   SingleValueState<V, Filter> copy(_SingleCopier updates) {
//     return FetchFailedSingleValueState(_delegate.rebuild(updates),
//         error: error);
//   }
// }
//
// typedef _SingleCopier = void Function(SingleValueStateDelegateBuilder b);
