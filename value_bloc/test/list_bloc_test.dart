import 'package:test/test.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

class TestPagesBloc extends ListBloc<int, Object> {
  static final values = List.generate(100, (index) => index);

  TestPagesBloc({
    LoadStatusValueBloc loadStatus = LoadStatusValueBloc.loaded,
    FetchStatusValueBloc fetchStatus = FetchStatusValueBloc.idle,
  }) : super(initialLoadStatus: loadStatus, initialFetchStatus: fetchStatus);

  @override
  void onLoading() => emitLoaded();

  @override
  void onFetching(int offset, [int limit]) {
    emitFetched(offset, limit, values.getRange(offset, offset + 2));
  }
}

void main() {
  group('Test PagesBloc', () {
    test('Success Fetched', () async {
      var fetchState = ListBlocState<int, Object>((b) => b
        ..loadStatus = LoadStatusValueBloc.idle
        ..fetchStatus = FetchStatusValueBloc.idle
        ..refreshStatus = false
        ..values);

      await runBlocTest<ListBloc<int, dynamic>, ListBlocState<int, dynamic>>(
        build: () => TestPagesBloc(loadStatus: LoadStatusValueBloc.idle),
        act: (cubit) async {
          cubit.load();
          await cubit.skip(1).first;
          print('Fetch 1');
          cubit.fetch(limit: 4);
          await cubit.skip(2).first;
          print('Fetch 2');
          cubit.fetch(offset: 4);
          await cubit.skip(1).first;
          print('Refresh');
          cubit.refresh();
          await cubit.skip(1).first;
          print('Update Filter');
          cubit.updateFilter(filter: 'filter');
          await cubit.skip(1).first;
        },
        expect: [
          fetchState =
              fetchState.rebuild((b) => b.loadStatus = LoadStatusValueBloc.loading),
          fetchState =
              fetchState.rebuild((b) => b.loadStatus = LoadStatusValueBloc.loaded),
          fetchState =
              fetchState.rebuild((b) => b.fetchStatus = FetchStatusValueBloc.fetching),
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetching
            ..values.pushRange(0, 2, TestPagesBloc.values)),
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetched
            ..values.pushRange(2, 4, TestPagesBloc.values.skip(2))),
          fetchState =
              fetchState.rebuild((b) => b.fetchStatus = FetchStatusValueBloc.fetching),
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetched
            ..values.pushRange(4, 6, TestPagesBloc.values.skip(4))),
          // Refresh -> 8
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetching
            ..refreshStatus = true
            ..values),
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetched
            ..refreshStatus = false
            ..values.clear()
            ..values.pushRange(0, 2, TestPagesBloc.values)),
          // Filter -> 10
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetching
            ..refreshStatus = true
            ..values
            ..filter = 'filter'),
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetched
            ..refreshStatus = false
            ..values.clear()
            ..values.pushRange(0, 2, TestPagesBloc.values)),
        ],
      );
    });
  });
}
