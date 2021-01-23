import 'package:equatable/equatable.dart';
import 'package:test/test.dart';
import 'package:value_bloc/ignore.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

void main() {
  EquatableConfig.stringify = true;

  group('Test ValueBloc', () {
    test('Success Load and Fetch', () async {
      SingleCubitState<int, int, $> state = SingleCubitFetching();
      await runCubitTest<SingleCubit<int, int, $>, SingleCubitState<int, int, $>>(
        build: () => SingleCubit<int, int, $>(
          fetcher: () async* {
            yield FetchEvent.fetched(value: 1);
          },
        )..listen(print),
        tests: [
          CubitTest(
            expect: [
              state,
              state,
              state = state.toValueFetched(value: 1),
            ],
          ),
          CubitTest(
            act: (c) => c.applyFilter(filter: 999),
            expect: [
              state = state.toFilteredFetching(filter: 999),
              state = state.toValueFetched(value: 1),
            ],
          ),
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
