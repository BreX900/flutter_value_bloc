import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';
import 'package:value_bloc/ignore.dart';
import 'package:value_bloc/src/internalUtils.dart';
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
            if (selection == IterableSection(0, 10)) {
              yield IterableFetchEvent.fetched(values.take(10));
            } else {
              yield IterableFetchEvent.fetched(values.skip(10).take(5));
            }
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(selection: IterableSection(0, 10)),
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
            // Fetch partial second page
            act: (c) => c.fetch(selection: IterableSection(10, 10)),
            expect: [
              state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addAll(values
                    .skip(10)
                    .take(5)
                    .toList()
                    .asMap()
                    .map((key, value) => MapEntry(key + 10, value)))),
              ),
            ],
          ),
          // CubitTest(
          //   act: (c) => c.applyFilter(scheme: IterableSection(0, 10)),
          //   expect: [
          //     state,
          //     state,
          //     state = state.toFetched(
          //         values: values.take(10).toBuiltList(), scheme: IterableSection(0, 10)),
          //   ],
          // ),
        ],
      );
    });
  });
}
