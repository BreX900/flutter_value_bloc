import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/utils.dart';

import '../fetchers.dart';

part 'MultiState.dart';

class MultiCubit<Value, Filter, ExtraData>
    extends Cubit<MultiCubitState<Value, Filter, ExtraData>> {
  final ListFetcherPlugin _fetcherPlugin;
  final _fetcherSubject = BehaviorSubject<ListFetcher<Value, Filter, ExtraData>>();
  final _schemesSubject = BehaviorSubject<BuiltSet<ListSection>>.seeded(BuiltSet.build((b) {
    b.withBase(() => HashSet());
  }));
  StreamSubscription _sub;
  final _subs = CompositeMapSubscription<ListSection>();

  MultiCubit({
    ListFetcherPlugin fetcherPlugin = const SimpleListFetcherPlugin(),
    ListFetcher<Value, Filter, ExtraData> fetcher,
    Filter filter,
    int countValues,
    ExtraData extraData,
  })  : _fetcherPlugin = fetcherPlugin,
        super(MultiCubitFetching(
          filter: filter,
          countValues: countValues,
          allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
          extraData: extraData,
        )) {
    if (fetcher != null) _fetcherSubject.add(fetcher);
    final dataStream = Rx.combineLatest2<ListFetcher<Value, Filter, ExtraData>,
        MultiCubitState<Value, Filter, ExtraData>, _Data<Value, Filter, ExtraData>>(
      _fetcherSubject,
      startWith(state).distinct((p, n) => p.filter == n.filter),
      (fetcher, state) {
        return _Data(state, fetcher);
      },
    ).shareValue();

    _sub = _schemesSubject.distinct().pairwise().listen((vls) {
      final newSchemes = vls.last.without(vls.first);
      final oldSchemes = vls.first.without(vls.last);

      // Remove old subscriptions
      oldSchemes.forEach(_subs.remove);

      // Add new subscriptions for every new scheme
      newSchemes.forEach((scheme) {
        _subs.add(
            scheme,
            dataStream.switchMap((data) {
              if (data.fetcher == null) return Stream.empty();

              emit(state.toFetching());

              return data.fetcher(data.state, scheme);
            }).listen((event) {
              if (event is FetchEmptyEvent<Iterable<Value>>) {
                emit(state.toEmptyFetched(scheme: scheme));
              } else if (event is FetchFailedEvent<Iterable<Value>>) {
                emit(state.toFetchFailed());
              } else if (event is FetchedEvent<Iterable<Value>>) {
                emit(state.toFetched(values: event.value.toBuiltList(), scheme: scheme));
              }
            }));
      });
    });
  }

  void fetch({@required ListSection scheme}) {
    final newSchemes = _fetcherPlugin.update(_schemesSubject.value, scheme);
    _schemesSubject.add(newSchemes);
  }

  void reFetch() {}

  void applyFilter({@required Filter filter}) {
    emit(state.toFilteredFetching(filter: filter));
    _fetcherSubject.add(_fetcherSubject.value);
  }

  void applyFetcher({@required ListFetcher<Value, Filter, ExtraData> fetcher}) {
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    _subs.dispose();
    return super.close();
  }
}

class _Data<Value, Filter, ExtraData> {
  final MultiCubitState<Value, Filter, ExtraData> state;
  final ListFetcher<Value, Filter, ExtraData> fetcher;

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
