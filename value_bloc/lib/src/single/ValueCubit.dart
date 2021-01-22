import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/utils.dart';
import 'package:value_bloc/src/utils.internal.dart';

part 'ValueState.dart';

class ValueCubit<Value, Filter, ExtraData> extends Cubit<CubitState<Value, Filter, ExtraData>> {
  final _fetcherSubject = BehaviorSubject<Fetcher<Value>>();

  ValueCubit._({
    @required Fetcher fetcher,
    @required bool hasValue,
    @required Value value,
  }) : super(hasValue
            ? ValueCubitFetched(hasValue: hasValue, value: value)
            : ValueCubitFetching(hasValue: hasValue, value: value)) {
    if (hasValue && fetcher != null) _fetcherSubject.add(fetcher);
    _fetcherSubject.withLatestFrom<Filter, _FetchData<Value, Filter>>(
      map((state) => state.filter).shareValueSeeded(state.filter).distinct(),
      (fetcher, filter) {
        return _FetchData(filter, fetcher);
      },
    ).switchMap((data) {
      return data.fetcher();
    }).listen((event) {
      if (event is FetchingEvent<Value>) {
        emit(state.toFetching(progress: event.progress));
      } else if (event is FetchEmptyEvent<Value>) {
        emit(state.toFetched(hasValue: false, value: null));
      } else if (event is FetchFailedEvent<Value>) {
        emit(state.toFetchFailed());
      } else if (event is FetchedEvent<Value>) {
        emit(state.toFetched(hasValue: true, value: event.value));
      }
    });
    if (!hasValue && fetcher != null) _fetcherSubject.add(fetcher);
  }

  ValueCubit({Fetcher fetcher}) : this._(fetcher: fetcher, value: null, hasValue: false);

  ValueCubit.of({
    Fetcher fetcher,
    @required Value value,
  }) : this._(fetcher: fetcher, value: value, hasValue: true);

  void updateFetcher({@required Fetcher<Value> fetcher, bool canFetch = true}) {
    if (_fetcherSubject.value == fetcher) return;
    emit(state.toFetching());
    _fetcherSubject.add(fetcher);
  }

  void updateFilter({@required Filter filter}) {
    emit(state.toFetchingWithExtraData(filter: filter));
    _fetcherSubject.add(_fetcherSubject.value);
  }

  void reFetch() {
    emit(state.toFetching());
    _fetcherSubject.add(_fetcherSubject.value);
  }
}

class _FetchData<Value, Filter> {
  final Filter filter;
  final Fetcher<Value> fetcher;

  _FetchData(this.filter, this.fetcher);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FetchData &&
          runtimeType == other.runtimeType &&
          filter == other.filter &&
          fetcher == other.fetcher;

  @override
  int get hashCode => filter.hashCode ^ fetcher.hashCode;
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
