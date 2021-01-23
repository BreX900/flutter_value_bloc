import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/src/list/ListValueStateDelegate.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

class TestPagesBloc extends ListValueCubit<int, Object> {
  static final values = List.generate(100, (index) => index);

  TestPagesBloc() : super(isLoading: true, fetcher: ListFetcher(minLimit: 2));

  @override
  void onLoading() => emitLoaded();

  @override
  void onFetching(FetchScheme scheme) {
    emitFetched(scheme, values.getRange(scheme.offset, scheme.end));
  }
}

void main() {
  group('Test PagesBloc', () {
    test('Success Fetched', () async {
      final filter = "I'm a filter";
      var delegate = ListValueStateDelegate<int, Object>((b) => b
        ..clearAfterFetch = false
        ..pages);

      await runBlocTest<ListValueCubit<int, dynamic>, ListValueState<int, dynamic>>(
        build: () => TestPagesBloc()..listen(testPrint),
        act: (cubit) async {
          // cubit.load();
          print('Loading');
          await cubit.first;
          print('Loaded -> Fetching');
          // cubit.fetch(limit: 4);
          await cubit.skip(1).first;
          print('Fetched -> Fetching');
          cubit.fetch(startAt: 4);
          await cubit.skip(1).first;
          print('Fetched -> Fetching | Refresh');
          cubit.refresh();
          await cubit.skip(1).first;
          print('Fetched -> Fetching | Update Filter');
          cubit.applyFilter(filter: filter);
          await cubit.first;
        },
        expect: [
          LoadingListValueState(delegate),
          LoadedListValueState(delegate),
          FetchingListValueState(delegate),
          FetchedListValueState(delegate = delegate.rebuild(
              (b) => b..pages[FetchScheme(0, 2)] = TestPagesBloc.values.take(2).toBuiltList())),
          FetchingListValueState(delegate),
          FetchedListValueState(delegate = delegate.rebuild((b) =>
              b..pages[FetchScheme(4, 2)] = TestPagesBloc.values.skip(4).take(2).toBuiltList())),
          // Refresh -> 6
          FetchingListValueState(delegate.rebuild((b) => b..clearAfterFetch = true)),
          FetchedListValueState(delegate = delegate.rebuild((b) => b
            ..clearAfterFetch = false
            ..pages.clear()
            ..pages[FetchScheme(0, 2)] = TestPagesBloc.values.take(2).toBuiltList())),
          // Filter -> 8
          FetchedListValueState(delegate.rebuild((b) => b..filter = filter)),
          // FetchingListValueState(delegate = delegate.rebuild((b) => b..filter = filter)),
          // FetchedListValueState(delegate = delegate.rebuild((b) => b
          //   ..pages.clear()
          //   ..pages[FetchScheme(0, 2)] = TestPagesBloc.values.take(2).toBuiltList())),
        ],
      );
    });

    test('test values without schemes', () {
      final state = FetchedListValueState(ListValueStateDelegate<int, Object>((b) => b
        ..clearAfterFetch = false
        ..pages));

      expect(state.values, BuiltMap<int, int>());
    });

    test('test values with single scheme', () {
      final state = FetchedListValueState(ListValueStateDelegate<int, Object>((b) => b
        ..clearAfterFetch = false
        ..pages.addAll({
          FetchScheme(0, 2): BuiltList([0, 1]),
        })));

      expect(
          state.values,
          BuiltMap<int, int>({
            0: 0,
            1: 1,
          }));
    });

    test('test values with more schemes', () {
      final state = FetchedListValueState(ListValueStateDelegate<int, Object>((b) => b
        ..clearAfterFetch = false
        ..pages.addAll({
          FetchScheme(0, 2): BuiltList([0, 1]),
          FetchScheme(2, 2): BuiltList([2, 3]),
        })));

      expect(
          state.values,
          BuiltMap<int, int>({
            0: 0,
            1: 1,
            2: 2,
            3: 3,
          }));
    });
  });
}
