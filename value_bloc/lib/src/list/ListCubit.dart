import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/utils.dart';

part 'ListState.dart';

typedef ListFetcher<Value> = Stream<FetchEvent<Value>> Function(ListSection section);

abstract class IterableCubit<Value, ExtraData> extends Cubit<IterableCubitState<Value, ExtraData>> {
  IterableCubit(IterableCubitState<Value, ExtraData> state) : super(state);

  void reset();
}

class ListCubit<Value, ExtraData> extends IterableCubit<Value, ExtraData> {
  ListCubit({
    Iterable<Value> values,
    ExtraData initialExtraData,
  }) : super(values == null
            ? IterableCubitUpdating(
                allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
                extraData: initialExtraData,
              )
            : IterableCubitUpdated(
                allValues: BuiltMap.build((b) => b
                  ..withBase(() => HashMap())
                  ..addAll(values.toList().asMap())),
                extraData: initialExtraData,
              ));

  // ==================================================
  //                          UI
  // ==================================================

  void update({@required Iterable<Value> values}) {
    emit(state.toUpdated(
      allValues: values.toList().asMap().build(),
    ));
  }

  void remove({@required Iterable<Value> values}) {
    emit(state.toRemoved(
      allValues: state.allValues.rebuild((b) {
        b.removeWhere((_, value) => values.contains(value));
      }),
    ));
  }

  void add({@required Iterable<Value> values}) {
    emit(state.toAdded(
      allValues: state.allValues.rebuild((b) => b.addAll(values.toList().asMap())),
    ));
  }

  @override
  void reset() {
    emit(state.toUpdating());
  }
}

class MultiCubit<Value, ExtraData> extends IterableCubit<Value, ExtraData> {
  final ListFetcherPlugin _fetcherPlugin;

  final _fetcherSubject = BehaviorSubject<ListFetcher<Value>>();
  final _schemesSubject = BehaviorSubject<BuiltSet<ListSection>>.seeded(BuiltSet.build((b) {
    b.withBase(() => HashSet());
  }));

  StreamSubscription _sub;
  final _subs = CompositeMapSubscription<ListSection>();

  MultiCubit({
    ListFetcherPlugin fetcherPlugin = const SimpleListFetcherPlugin(),
    Map<int, Value> initialAllValues,
    ExtraData initialExtraData,
  })  : _fetcherPlugin = fetcherPlugin,
        super(IterableCubitIdle(
          allValues: BuiltMap.build((b) {
            b.withBase(() => HashMap());
            if (initialAllValues != null) b.addAll(initialAllValues);
          }),
          extraData: initialExtraData,
          oldAllValues: null,
        )) {
    _sub = _schemesSubject.pairwise().listen((vls) {
      final newSchemes = vls.last.without(vls.first);
      final oldSchemes = vls.first.without(vls.last);

      // Remove old subscriptions and values
      oldSchemes.forEach((scheme) async {
        await _subs.remove(scheme);
        emit(state.toUpdated(
          allValues: state.allValues.rebuild((b) {
            for (var i = scheme.startAt; i < scheme.endAt; i++) {
              b.remove(i);
            }
          }),
        ));
      });

      if (newSchemes.isNotEmpty) emit(state.toUpdating());

      // Add new subscriptions for every new scheme and add values
      newSchemes.forEach((scheme) {
        _fetcherSubject.switchMap((fetcher) {
          if (fetcher == null) return Stream.empty();
          return fetcher(scheme);
        }).listen((event) {
          if (event is FetchFailedEvent<Iterable<Value>>) {
          } else if (event is FetchedEvent<Iterable<Value>>) {
            final page = event.value;

            emit(state.toUpdated(
              allValues: state.allValues.rebuild((b) {
                try {
                  for (var i = scheme.startAt; i < scheme.endAt; i++) {
                    b[i] = page.elementAt(i);
                  }
                } on IndexError {
                  // ignore: empty_catches
                }
              }),
              valuesCount: scheme.endAt - 1 < page.length ? page.length : state.valuesCount,
            ));
          }
        }).addToByKey(_subs, scheme);
      });
    });
  }

  // ==================================================
  //                        CUBIT
  // ==================================================

  void applyFetcher({@required ListFetcher<Value> fetcher}) {
    assert(fetcher != null);
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  // ==================================================
  //                          UI
  // ==================================================

  void fetch({@required ListSection scheme}) {
    final newSchemes = _fetcherPlugin.update(_schemesSubject.value, scheme);
    _schemesSubject.add(newSchemes);
  }

  @override
  void reset() async {
    _schemesSubject.add(_schemesSubject.value.rebuild((b) => b.clear()));
    emit(state.toIdle());
  }

  // ==================================================
  //                        IGNORE
  // ==================================================

  @override
  Future<void> close() {
    _subs.dispose();
    _sub.cancel();
    _fetcherSubject.close();
    _schemesSubject.close();
    return super.close();
  }
}
