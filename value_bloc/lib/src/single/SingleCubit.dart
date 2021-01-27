import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/utils.dart';

part 'SingleState.dart';

class SingleCubit<Value, Filter, ExtraData>
    extends Cubit<SingleCubitState<Value, Filter, ExtraData>> {
  final _fetcherSubject = BehaviorSubject<ValueFetcher<Value, Filter, ExtraData>>();
  StreamSubscription _fetcherSub;

  SingleCubit._({
    @required ValueFetcher<Value, Filter, ExtraData> fetcher,
    @required bool isEmpty,
    @required Value value,
  }) : super(isEmpty
            ? SingleCubitFetched(isEmpty: isEmpty, value: value)
            : SingleCubitFetching(value: value)) {
    if (fetcher != null) _fetcherSubject.add(fetcher);
    _fetcherSub = Rx.combineLatest2<ValueFetcher<Value, Filter, ExtraData>,
        SingleCubitState<Value, Filter, ExtraData>, _Data<Value, Filter, ExtraData>>(
      _fetcherSubject,
      startWith(state).distinct((p, n) => p.filter == n.filter),
      (fetcher, state) {
        return _Data(state, fetcher);
      },
    ).switchMap((data) {
      if (data.fetcher == null) return Stream.empty();
      emit(state.toFetching());
      return data.fetcher(data.state);
    }).listen((event) {
      if (event is FetchEmptyEvent<Value>) {
        emit(state.toEmptyFetched());
      } else if (event is FetchFailedEvent<Value>) {
        emit(state.toFailed());
      } else if (event is FetchedEvent<Value>) {
        emit(state.toValueFetched(value: event.value));
      }
    });
  }

  SingleCubit({ValueFetcher<Value, Filter, ExtraData> fetcher})
      : this._(fetcher: fetcher, value: null, isEmpty: false);

  SingleCubit.of({
    ValueFetcher<Value, Filter, ExtraData> fetcher,
    @required Value value,
  }) : this._(fetcher: fetcher, value: value, isEmpty: false);

  SingleCubit.empty({ValueFetcher<Value, Filter, ExtraData> fetcher})
      : this._(fetcher: fetcher, value: null, isEmpty: true);

  void applyFetcher({
    @required ValueFetcher<Value, Filter, ExtraData> fetcher,
    bool canFetch = true,
  }) {
    if (_fetcherSubject.value == fetcher) return;
    emit(state.toFetching());
    _fetcherSubject.add(fetcher);
  }

  void applyFilter({@required Filter filter}) {
    emit(state.toFilteredFetching(filter: filter));
  }

  void reFetch() {
    emit(state.toFetching());
    _fetcherSubject.add(_fetcherSubject.value);
  }

  @override
  Future<void> close() {
    _fetcherSub.cancel();
    return super.close();
  }
}

class _Data<Value, Filter, ExtraData> {
  final SingleCubitState<Value, Filter, ExtraData> state;
  final ValueFetcher<Value, Filter, ExtraData> fetcher;

  _Data(this.state, this.fetcher);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Data &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          fetcher == other.fetcher;

  @override
  int get hashCode => state.hashCode ^ fetcher.hashCode;
}

// abstract class SingleValueCubit<V, Filter extends Object>
//     extends ValueCubit<SingleValueState<V, Filter>, Filter> {
//   SingleValueCubit({
//     bool isLoading = false,
//     bool isFetching = true,
//     V initialValue,
//     Filter initialFilter,
//   }) : super(
//           IdleSingleValueState(SingleValueStateDelegate<V, Filter>((b) => b
//             ..clearAfterFetch = false
//             ..value = initialValue
//             ..filter = initialFilter)),
//           isLoading,
//           isFetching,
//           initialFilter,
//         );
//
//   /// Override this method for fetching value
//   /// Call [emitFetched] when fetching is completed
//   void onFetching();
//
//   /// Call this method when fetching is completed
//   void emitFetched(V value) async {
//     await Future.delayed(Duration.zero);
//     if (!(state is FetchingValueState<Filter> || state is FetchedValueState<Filter>)) {
//       ValueCubitObserver.instance.methodIgnored(state, 'emitSuccessFetched(value:$value)');
//       return;
//     }
//     emit(state.toFetched(value));
//   }
//
//   /// This method call the onFetching user method
//   /// The call of this method is ignored if the fetchStatus is fetching or fetched
//   @override
//   void fetch() async {
//     await Future.delayed(Duration.zero);
//     if (!state.canFetch) {
//       ValueCubitObserver.instance.methodIgnored(state, 'fetch()');
//       return;
//     }
//     emit(state.toFetching());
//     onFetching();
//   }
//
//   @override
//   void firstFetchingHandle() => onFetching();
// }
