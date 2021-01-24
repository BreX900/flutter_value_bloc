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

  group('Test PagesBloc', () {
    test('Success Fetch two page and filter', () async {
      MultiCubitState<int, int, $> state = MultiCubitFetching<int, int, $>(
        filter: null,
        countValues: null,
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, int, $>, MultiCubitState<int, int, $>>(
        build: () => MultiCubit<int, int, $>(
          fetcher: (state, scheme) async* {
            if (scheme == FetchScheme(0, 10)) {
              yield FetchEvent.fetched(value: values.take(10));
            } else {
              yield FetchEvent.fetched(value: values.skip(10).take(5));
            }
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(scheme: FetchScheme(0, 10)),
            expect: [
              state,
              state,
              state = state.toFetched(
                  values: values.take(10).toBuiltList(), scheme: FetchScheme(0, 10)),
            ],
          ),
          CubitTest(
            // Fetch partial second page
            act: (c) => c.fetch(scheme: FetchScheme(10, 10)),
            expect: [
              state.toFetching(),
              state = state.toFetched(
                values: values.skip(10).take(5).toBuiltList(),
                scheme: FetchScheme(10, 10),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.applyFilter(scheme: FetchScheme(0, 10)),
            expect: [
              state,
              state,
              state = state.toFetched(
                  values: values.take(10).toBuiltList(), scheme: FetchScheme(0, 10)),
            ],
          ),
        ],
      );
    });
  });
}
