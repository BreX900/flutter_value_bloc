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

abstract class BaseListCubit<Value, ExtraData> extends Cubit<ListCubitState<Value, ExtraData>> {
  BaseListCubit(ListCubitState<Value, ExtraData> state) : super(state);

  void clear();
}

class ListCubit<Value, ExtraData> extends BaseListCubit<Value, ExtraData> {
  ListCubit({
    Iterable<Value> values = const [],
    ExtraData initialExtraData,
  }) : super(ListCubitUpdated(allValues: BuiltList<Value>(values), extraData: initialExtraData));

  void update({@required Iterable<Value> values}) {
    emit(state.toUpdated(allValues: values));
  }

  void remove({@required Iterable<Value> values}) {
    emit(state.toRemoved(allValues: state.allValues.rebuild((b) => values.forEach(b.remove))));
  }

  void add({@required Iterable<Value> values}) {
    emit(state.toAdded(allValues: state.allValues.rebuild((b) => b.addAll(values))));
  }

  @override
  void clear() {
    emit(state.toEmpty());
  }
}

class MultiCubit<Value, ExtraData> extends BaseListCubit<Value, ExtraData> {
  final ListFetcherPlugin _fetcherPlugin;

  final _fetcherSubject = BehaviorSubject<ListFetcher<Value>>();
  final _schemesSubject = BehaviorSubject<BuiltSet<ListSection>>.seeded(BuiltSet.build((b) {
    b.withBase(() => HashSet());
  }));
  var _pages = BuiltMap<ListSection, BuiltList<Value>>.build((b) {
    b.withBase(() => HashMap(hashCode: (scheme) => scheme.startAt));
  });

  StreamSubscription _sub;
  final _subs = CompositeMapSubscription<ListSection>();

  MultiCubit({
    ListFetcherPlugin fetcherPlugin = const SimpleListFetcherPlugin(),
    ExtraData initialExtraData,
  })  : _fetcherPlugin = fetcherPlugin,
        super(ListCubitEmpty(
          allValues: BuiltList<Value>(),
          extraData: initialExtraData,
          oldAllValues: null,
        )) {
    _sub = _schemesSubject.pairwise().listen((vls) {
      final newSchemes = vls.last.without(vls.first);
      final oldSchemes = vls.first.without(vls.last);

      // Remove old subscriptions and pages
      oldSchemes.forEach((scheme) async {
        await _subs.remove(scheme);
        _pages = _pages.rebuild((b) => b.remove(scheme));
      });

      if (newSchemes.isNotEmpty) emit(state.toUpdating());

      // Add new subscriptions for every new scheme
      newSchemes.forEach((scheme) {
        _fetcherSubject.switchMap((fetcher) {
          if (fetcher == null) return Stream.empty();
          return fetcher(scheme);
        }).listen((event) {
          if (event is FetchFailedEvent<Iterable<Value>>) {
          } else if (event is FetchedEvent<Iterable<Value>>) {
            final page = event.value;
            _pages = _pages.rebuild((b) => b[scheme] = page);

            final valuesCount = _pages.keys.tryLast?.endAt ?? 0;
            final values = List<Value>(valuesCount);
            _pages.forEach((scheme, page) {
              values.setAll(scheme.startAt, page);
            });

            emit(state.toUpdated(
              allValues: values.toBuiltList(),
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
    if (_fetcherSubject.value == fetcher) return;
    _fetcherSubject.add(fetcher);
  }

  // ==================================================
  //                          UI
  // ==================================================

  @override
  void clear() async {
    _schemesSubject.add(_schemesSubject.value.rebuild((b) => b.clear()));
    emit(state.toEmpty());
  }

  void fetch({@required ListSection scheme}) {
    final newSchemes = _fetcherPlugin.update(_schemesSubject.value, scheme);
    _schemesSubject.add(newSchemes);
  }

  @override
  Future<void> close() {
    _subs.dispose();
    _sub.cancel();
    return super.close();
  }
}
