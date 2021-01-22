import 'package:test/test.dart';
import 'package:value_bloc/src/single/SingleValueStateDelegate.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

class TestValueBloc extends ValueCubit<int, Object> {
  TestValueBloc() : super(isLoading: true);

  @override
  void onLoading() => emitLoaded();

  @override
  void onFetching() => emitFetched(1);
}

void main() {
  group('Test ValueBloc', () {
    test('Success Load and Fetch', () async {
      var delegate = getValueBlocState<int>();
      await runBlocTest<ValueCubit<int, dynamic>, CubitState<int, dynamic>>(
        build: () => TestValueBloc(),
        act: (cubit) async {
          print('Loading');
          await cubit.first;
          print('Loaded -> Fetching');
          await cubit.skip(1).first;
          print('Fetched');
        },
        expect: [
          LoadingSingleValueState(delegate),
          SuccessLoadedSingleValueState(delegate),
          ValueCubitFetching(delegate),
          ValueCubitFetched(delegate.rebuild((b) => b..value = 1)),
        ],
      );
    });

    // test('Success Auto Loaded and Fetched', () async {
    //   var fetchState = getValueBlocState<int>();
    //   await runBlocTest<SingleValueCubit<int, dynamic>,
    //       SingleValueState<int, dynamic>>(
    //     build: () => TestValueBloc(loadStatus: loadStatus),
    //     act: (cubit) async {
    //       await cubit.first;
    //       print('Fetch');
    //       await cubit.first;
    //     },
    //     expect: [
    //       fetchState =
    //           fetchState.rebuild((b) => b.loadStatus = LoadStatus.loaded),
    //       fetchState = fetchState.rebuild((b) => b
    //         ..fetchStatus = FetchStatus.fetched
    //         ..value = 1)
    //     ],
    //   );
    // });
  });
}

SingleValueStateDelegate<T, Object> getValueBlocState<T>({
  T value,
}) =>
    SingleValueStateDelegate<T, Object>((b) => b
      ..clearAfterFetch = false
      ..value = value);
