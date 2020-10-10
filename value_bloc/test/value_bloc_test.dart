import 'package:test/test.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

class TestValueBloc extends ValueBloc<int, Object> {
  TestValueBloc({
    LoadStatusValueBloc loadStatus = LoadStatusValueBloc.loaded,
    FetchStatusValueBloc fetchStatus = FetchStatusValueBloc.fetching,
  }) : super(initialLoadStatus: loadStatus, initialFetchStatus: fetchStatus);

  @override
  void onLoading() => emitLoaded();

  @override
  void onFetching() => emitFetched(1);
}

void main() {
  group('Test ValueBloc', () {
    test('Success Fetched', () async {
      final loadStatus = LoadStatusValueBloc.idle;
      final fetchStatus = FetchStatusValueBloc.idle;
      var fetchState = getValueBlocState<int>(
        loadStatus: loadStatus,
        fetchStatus: fetchStatus,
      );
      await runBlocTest<ValueBloc<int, dynamic>, ValueBlocState<int, dynamic>>(
        build: () => TestValueBloc(
          loadStatus: loadStatus,
          fetchStatus: fetchStatus,
        ),
        act: (cubit) async {
          cubit.load();
          await cubit.skip(1).first;
          print('Fetch');
          cubit.fetch();
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
            ..fetchStatus = FetchStatusValueBloc.fetched
            ..value = 1)
        ],
      );
    });

    test('Success Auto Loaded and Fetched', () async {
      final loadStatus = LoadStatusValueBloc.loading;
      var fetchState = getValueBlocState<int>(loadStatus: loadStatus);
      await runBlocTest<ValueBloc<int, dynamic>, ValueBlocState<int, dynamic>>(
        build: () => TestValueBloc(loadStatus: loadStatus),
        act: (cubit) async {
          await cubit.first;
          print('Fetch');
          await cubit.first;
        },
        expect: [
          fetchState =
              fetchState.rebuild((b) => b.loadStatus = LoadStatusValueBloc.loaded),
          fetchState = fetchState.rebuild((b) => b
            ..fetchStatus = FetchStatusValueBloc.fetched
            ..value = 1)
        ],
      );
    });
  });
}

ValueBlocState<T, Object> getValueBlocState<T>({
  LoadStatusValueBloc loadStatus = LoadStatusValueBloc.loaded,
  FetchStatusValueBloc fetchStatus = FetchStatusValueBloc.fetching,
  T value,
}) =>
    ValueBlocState<T, Object>((b) => b
      ..loadStatus = loadStatus
      ..fetchStatus = fetchStatus
      ..refreshStatus = false
      ..value = value);
