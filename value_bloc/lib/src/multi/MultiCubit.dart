import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/utils.dart';

part 'MultiState.dart';

class MultiCubit<Value, Filter, ExtraData>
    extends Cubit<MultiCubitState<Value, Filter, ExtraData>> {
  final ListFetcherPlugin _fetcherPlugin;
  final _fetcherSubject = BehaviorSubject<ListFetcher<Value>>();
  final _schemesSubject = BehaviorSubject<BuiltSet<FetchScheme>>.seeded(BuiltSet());
  StreamSubscription _sub;
  final _subs = CompositeMapSubscription<FetchScheme>();

  MultiCubit({
    ListFetcherPlugin fetcherPlugin = const BaseFetchSchemeQueue(),
    ListFetcher<Value> fetcher,
    Filter filter,
    int countValues,
    ExtraData extraData,
  })  : _fetcherPlugin = fetcherPlugin,
        super(MultiCubitFetching(
          filter: filter,
          countValues: countValues,
          // allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
          allValues: BuiltMap(),
          extraData: extraData,
        )) {
    final dataStream = _fetcherSubject
        .withLatestFrom<MultiCubitState<Value, Filter, ExtraData>, _Data<Value, Filter>>(
      shareValueSeeded(state).distinct((p, n) => p.filter != n.filter),
      (fetcher, state) {
        return _Data(state.filter, fetcher);
      },
    ).shareValue();

    _sub = _schemesSubject.distinct().pairwise().listen((vls) {
      final newSchemes = vls.last.without(vls.first);

      for (var scheme in newSchemes) {
        _subs.putIfAbsent(scheme, () {
          return dataStream.switchMap((data) {
            if (data.fetcher == null) return Stream.empty();

            emit(state.toFetching());

            return data.fetcher(scheme.startAt, scheme.length);
          }).listen((event) {
            if (event is FetchEmptyEvent<Iterable<Value>>) {
              emit(state.toEmptyFetched(scheme: scheme));
            } else if (event is FetchFailedEvent<Iterable<Value>>) {
              emit(state.toFetchFailed());
            } else if (event is FetchedEvent<Iterable<Value>>) {
              emit(state.toFetched(values: event.value.toBuiltList(), scheme: scheme));
            }
          });
        });
      }
    });
  }

  void fetch({@required FetchScheme scheme}) {
    final newSchemes = _fetcherPlugin.update(_schemesSubject.value, scheme);
    _schemesSubject.add(newSchemes);
  }

  void reFetch() {}

  void applyFilter({@required Filter filter}) {
    emit(state.toFilteredFetching(filter: filter));
    _fetcherSubject.add(_fetcherSubject.value);
  }

  void applyFetcher({@required ListFetcher<Value> fetcher}) {
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  @override
  Future<void> close() async {
    await _subs.dispose();
    return super.close();
  }
}

class _Data<Value, Filter> {
  final Filter filter;
  final ListFetcher<Value> fetcher;

  _Data(this.filter, this.fetcher);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Data &&
          runtimeType == other.runtimeType &&
          filter == other.filter &&
          fetcher == other.fetcher;

  @override
  int get hashCode => filter.hashCode ^ fetcher.hashCode;
}

abstract class ListFetcherPlugin {
  const ListFetcherPlugin();

  BuiltSet<FetchScheme> update(BuiltSet<FetchScheme> schemes, FetchScheme newScheme);
}

abstract class IgnoreSchemeQueue {}

class BaseFetchSchemeQueue extends ListFetcherPlugin {
  const BaseFetchSchemeQueue();

  /// find in queue the first scheme contains the offset
  FetchScheme findContainer(BuiltSet<FetchScheme> queue, int offset) {
    return queue.firstWhere((s) => s.containsOffset(offset), orElse: () => null);
  }

  /// find in the queue for the first possible not-existent scheme offset
  ///
  /// Returns null if the offset exist
  int findFirstNotExistOffset(BuiltSet<FetchScheme> queue, FetchScheme scheme) {
    for (var i = scheme.startAt; i < scheme.endAt; i++) {
      final container = findContainer(queue, scheme.startAt);
      if (container == null) {
        return i;
      } else {
        i = container.endAt;
      }
    }
    return null;

    int newOffset;

    do {
      final container = findContainer(queue, newOffset ?? scheme.startAt);

      if (container != null) {
        if (scheme.endAt > container.endAt) {
          // find next not exist possible offset
          newOffset = scheme.endAt - (scheme.endAt - container.endAt);
        } else {
          // all possible offset exist
          return null;
        }
      }
    } while (newOffset != null && newOffset > 0);

    // if not find a any container for scheme therefore the scheme offset not exist
    return newOffset ?? scheme.startAt;
  }

  /// find in the queue for the first possible existent scheme offset
  ///
  /// Returns null if the offset not exist
  int findFirstExistOffset(BuiltSet<FetchScheme> queue, FetchScheme scheme) {
    for (var i = scheme.startAt; i < scheme.endAt; i++) {
      final container = findContainer(queue, scheme.startAt);
      if (container != null) return i;
    }
    return null;
  }

  @override
  BuiltSet<FetchScheme> update(BuiltSet<FetchScheme> queue, FetchScheme scheme) {
    do {
      final newStartAt = findFirstNotExistOffset(queue, scheme);
      if (newStartAt == null) return queue;
      final startScheme = scheme.mergeWith(startAt: newStartAt);
      final newEndAt = findFirstExistOffset(queue, startScheme);
      final newScheme = newEndAt == null ? startScheme : startScheme.mergeWith(endAt: newEndAt);

      queue = queue.rebuild((b) => b.add(scheme));
      scheme = newScheme.endAt >= scheme.endAt ? null : scheme.mergeWith(startAt: newScheme.endAt);
    } while (scheme == null);

    return queue;
  }
}
