import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/src/list/ListValueStateDelegate.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

class TestPagesBloc extends ListValueCubit<int, Object> {
  static final values = List.generate(100, (index) => index);

  TestPagesBloc({
    LoadStatus loadStatus = LoadStatus.loaded,
    FetchStatus fetchStatus = FetchStatus.idle,
  }) : super(isLoading: true, fetcher: ListFetcher(minLimit: 2));

  @override
  void onLoading() => emitSuccessLoaded();

  @override
  void onFetching(FetchScheme scheme) {
    emitSuccessFetched(scheme, values.getRange(scheme.offset, scheme.end));
  }
}

void main() {
  group('Test PagesBloc', () {
    test('Success Fetched', () async {
      final filter = "I'm a filter";
      var delegate = ListValueStateDelegate<int, Object>((b) => b..pages);

      await runBlocTest<ListValueCubit<int, dynamic>, ListValueState<int, dynamic>>(
        build: () => TestPagesBloc(loadStatus: LoadStatus.idle)..listen(testPrint),
        act: (cubit) async {
          // cubit.load();
          print('Loading');
          await cubit.first;
          print('Loaded -> Fetching');
          // cubit.fetch(limit: 4);
          await cubit.skip(1).first;
          print('Fetched -> Fetching');
          cubit.fetch(offset: 4);
          await cubit.skip(1).first;
          print('Fetched -> Fetching | Refresh');
          cubit.refresh();
          await cubit.skip(1).first;
          print('Fetched -> Fetching | Update Filter');
          cubit.updateFilter(filter: filter);
          await cubit.skip(1).first;
        },
        expect: [
          LoadingListValueState(delegate),
          SuccessLoadedListValueState(delegate),
          FetchingListValueState(delegate),
          SuccessFetchedListValueState(delegate = delegate.rebuild((b) =>
              b..pages[FetchScheme(0, 2)] = TestPagesBloc.values.take(2).toBuiltList())),
          FetchingListValueState(delegate),
          SuccessFetchedListValueState(delegate = delegate.rebuild((b) => b
            ..pages[FetchScheme(4, 2)] =
                TestPagesBloc.values.skip(4).take(2).toBuiltList())),
          // Refresh -> 6
          FetchingListValueState(delegate),
          SuccessFetchedListValueState(delegate = delegate.rebuild((b) => b
            ..pages.clear()
            ..pages[FetchScheme(0, 2)] = TestPagesBloc.values.take(2).toBuiltList())),
          // Filter -> 8
          FetchingListValueState(delegate = delegate.rebuild((b) => b..filter = filter)),
          SuccessFetchedListValueState(delegate = delegate.rebuild((b) => b
            ..pages.clear()
            ..pages[FetchScheme(0, 2)] = TestPagesBloc.values.take(2).toBuiltList())),
        ],
      );
    });
  });
}
