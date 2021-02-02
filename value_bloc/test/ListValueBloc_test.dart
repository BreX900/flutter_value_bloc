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
    test('Success Fetch two page and filter', () async {
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

    test('Success Fetch partial page', () async {
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
