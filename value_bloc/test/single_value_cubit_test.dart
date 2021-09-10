import 'package:equatable/equatable.dart';
import 'package:test/test.dart';
import 'package:value_bloc/ignore.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

void main() {
  EquatableConfig.stringify = true;

  group('Test ObjectCubit', () {
    test('Test basic ValueCubit', () async {
      ObjectCubitState<int?, $?> state = ObjectCubitUpdating(oldValue: null);
      await runCubitTest<ValueCubit<int, $>, ObjectCubitState<int, $>>(
        build: () => ValueCubit<int, $>()..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.update(value: 1),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(hasValue: true, value: 1),
            ],
          ),
          CubitTest(
            act: (c) => c.clear(),
            expect: [
              state = state.toUpdated(hasValue: false, value: null),
            ],
          ),
          CubitTest(
            act: (c) => c.reset(),
            expect: [
              state = state.toUpdating(),
            ],
          ),
          CubitTest(
            act: (c) => c.update(value: 2),
            expect: [
              state = state.toUpdated(hasValue: true, value: 2),
            ],
          ),
        ],
      );
    });
  });

  group('Test SingleCubit', () {
    test('Fetching values on start and after reset', () async {
      ObjectCubitState<int?, $?> state = ObjectCubitUpdating(oldValue: null);
      await runCubitTest<SingleCubit<int, $, $>, ObjectCubitState<int, $>>(
        wait: Duration(milliseconds: 100),
        build: () => SingleCubit<int, $, $>(
          fetcher: (filter) async* {
            yield SingleFetchEvent.fetched(1);
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state,
              state,
              state = ObjectCubitUpdated(hasValue: true, value: 1, oldValue: null),
            ],
          ),
          CubitTest(
            act: (c) => c.reset(),
            expect: [
              state = ObjectCubitUpdating(oldValue: 1),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state = ObjectCubitUpdated(hasValue: true, value: 1, oldValue: 1),
            ],
          ),
        ],
      );
    });

    test('Apply filter after first fetch', () async {
      ObjectCubitState<int?, $?> state = ObjectCubitUpdating(oldValue: null);
      await runCubitTest<SingleCubit<int, $, $>, ObjectCubitState<int, $>>(
        wait: Duration(milliseconds: 100),
        build: () => SingleCubit<int, $, $>(
          fetcher: (filter) async* {
            yield SingleFetchEvent.fetched(filter != null ? 2 : 1);
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state,
              state,
              state = state.toUpdated(hasValue: true, value: 1),
            ],
          ),
          CubitTest(
            act: (c) => c.applyFilter(filter: $()),
            expect: [
              state = state.toUpdating(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state = state.toUpdated(hasValue: true, value: 2),
            ],
          ),
        ],
      );
    });
  });
}
