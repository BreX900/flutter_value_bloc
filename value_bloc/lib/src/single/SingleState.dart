part of 'SingleCubit.dart';

typedef ValueFetcher<V> = Stream<FetchEvent<V>> Function();

abstract class SingleCubitState<Value, Filter, ExtraData> with EquatableMixin {
  final Filter filter;
  final Value value;
  final ExtraData extraData;

  SingleCubitState({
    @required this.filter,
    @required this.value,
    @required this.extraData,
  });

  SingleCubitState<Value, Filter, ExtraData> toFilteredFetching({
    double progress = 0.0,
    Filter filter,
  }) {
    return SingleCubitFetching(
      filter: filter,
      value: value,
      extraData: extraData,
    );
  }

  SingleCubitState<Value, Filter, ExtraData> toFetching({double progress = 0.0}) {
    return SingleCubitFetching(
      filter: filter,
      value: value,
      extraData: extraData,
    );
  }

  SingleCubitState<Value, Filter, ExtraData> toFailed({Object failure}) {
    return SingleCubitFailed(
      filter: filter,
      value: value,
      failure: failure,
      extraData: extraData,
    );
  }

  SingleCubitState<Value, Filter, ExtraData> toEmptyFetched() {
    return SingleCubitFetched(
      filter: filter,
      isEmpty: true,
      value: null,
      extraData: extraData,
    );
  }

  SingleCubitState<Value, Filter, ExtraData> toValueFetched({@required Value value}) {
    return SingleCubitFetched(
      filter: filter,
      isEmpty: false,
      value: value,
      extraData: extraData,
    );
  }

  @override
  List<Object> get props => [filter, value, extraData];
}

class SingleCubitFetching<Value, Filter, ExtraData>
    extends SingleCubitState<Value, Filter, ExtraData> {
  SingleCubitFetching({
    Filter filter,
    Value value,
    ExtraData extraData,
  }) : super(
          filter: filter,
          value: value,
          extraData: extraData,
        );
}

class SingleCubitFailed<Value, Filter, ExtraData>
    extends SingleCubitState<Value, Filter, ExtraData> {
  final Object failure;

  SingleCubitFailed({
    Filter filter,
    Value value,
    this.failure,
    ExtraData extraData,
  }) : super(
          filter: filter,
          value: value,
          extraData: extraData,
        );

  @override
  List<Object> get props => super.props..add(failure);
}

class SingleCubitFetched<Value, Filter, ExtraData>
    extends SingleCubitState<Value, Filter, ExtraData> {
  final bool isEmpty;

  SingleCubitFetched({
    Filter filter,
    @required this.isEmpty,
    @required Value value,
    ExtraData extraData,
  })  : assert(isEmpty != null),
        super(
          filter: filter,
          value: value,
          extraData: extraData,
        );

  @override
  List<Object> get props => super.props..add(isEmpty);
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
