import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';
import 'package:value_bloc/ignore.dart';
import 'package:value_bloc/value_bloc.dart';

import 'utility.dart';

void main() {
  EquatableConfig.stringify = true;
  final values = List.generate(100, (index) => index);

  group('Test IterableCubit', () {
    test('Fetch on page and stop after second page is empty', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (selection) async* {
            if (selection == IterableSection(10, 10)) {
              yield IterableFetchEvent.empty();
            } else {
              yield IterableFetchEvent.fetched(values.take(10));
            }
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(10).toList().asMap())),
              ),
            ],
          ),
          CubitTest(
            // Fetch empty second page
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state.toUpdating(),
              state = state.toUpdated(
                length: 10,
              ),
            ],
          ),
        ],
      );
    });

    test('Set length and fetch partial data', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (selection) async* {
            yield IterableFetchEvent.fetched(values.take(3));
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(3).toList().asMap())),
                length: 3,
              ),
            ],
          ),
        ],
      );
    });

    test('When change the fetcher clean all values and refetch', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (selection) async* {
            yield IterableFetchEvent.fetched(values.take(3));
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(3).toList().asMap())),
                length: 3,
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.reset(),
            expect: [
              state = state.toIdle(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(3).toList().asMap())),
                length: 3,
              ),
            ],
          ),
        ],
      );
    });

    // Todo...
    test('Length change and ', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (selection) async* {
            yield IterableFetchEvent.fetched(values.take(3));
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(3).toList().asMap())),
                length: 3,
              ),
            ],
          ),
        ],
      );
    });
  });
}
