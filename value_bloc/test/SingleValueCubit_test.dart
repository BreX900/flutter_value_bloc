import 'package:equatable/equatable.dart';
import 'package:test/test.dart';
import 'package:value_bloc/ignore.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

void main() {
  EquatableConfig.stringify = true;

  group('Test ObjectCubit', () {
    test('Test basic ValueCubit', () async {
      ObjectCubitState<int, $> state = ObjectCubitIdle();
      await runCubitTest<ValueCubit<int, $>, ObjectCubitState<int, $>>(
        build: () => ValueCubit<int, $>()..listen(print),
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
      ObjectCubitState<int, $> state = ObjectCubitIdle();
      await runCubitTest<SingleCubit<int, $, $>, ObjectCubitState<int, $>>(
        wait: Duration(milliseconds: 100),
        build: () => SingleCubit<int, $, $>(
          fetcher: (filter) async* {
            yield ObjectFetchEvent.fetched(1);
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(hasValue: true, value: 1),
            ],
          ),
          CubitTest(
            act: (c) => c.reset(),
            expect: [
              state = state.toIdle(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(hasValue: true, value: 1),
            ],
          ),
        ],
      );
    });

    test('Apply filter after first fetch', () async {
      ObjectCubitState<int, $> state = ObjectCubitIdle();
      await runCubitTest<SingleCubit<int, $, $>, ObjectCubitState<int, $>>(
        wait: Duration(milliseconds: 100),
        build: () => SingleCubit<int, $, $>(
          fetcher: (filter) async* {
            yield ObjectFetchEvent.fetched(filter != null ? 2 : 1);
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(hasValue: true, value: 1),
            ],
          ),
          CubitTest(
            act: (c) => c.applyFilter(filter: $()),
            expect: [
              state = state.toIdle(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(hasValue: true, value: 2),
            ],
          ),
        ],
      );
    });
  });
}
