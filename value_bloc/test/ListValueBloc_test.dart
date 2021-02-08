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
    test('Fetch on page and stop after four page is empty', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (selection) async* {
            if (selection == IterableSection(30, 10)) {
              yield IterableFetchEvent.empty();
            } else {
              yield IterableFetchEvent.fetched(
                values.skip(selection.startAt).take(selection.length),
              );
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
                allValues: state.allValues
                    .rebuild((b) => b.addAll(values.take(10).toList().asMap())),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10,
                        (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(20, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10,
                        (index) => MapEntry(index + 20, values[index + 20])))),
              ),
            ],
          ),
          CubitTest(
            // Fetch empty second page
            act: (c) => c.fetch(section: IterableSection(30, 10)),
            expect: [
              state.toUpdating(),
              state = state.toUpdated(
                length: 30,
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
          fetcher: (section) async* {
            if (section == IterableSection(20, 10)) {
              yield IterableFetchEvent.fetched(values.skip(20).take(3));
            } else {
              yield IterableFetchEvent.fetched(
                  values.skip(section.startAt).take(section.length));
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
                allValues: state.allValues
                    .rebuild((b) => b.addAll(values.take(10).toList().asMap())),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10,
                        (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(20, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(3,
                        (index) => MapEntry(index + 20, values[index + 20])))),
                length: 23,
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
                allValues: state.allValues
                    .rebuild((b) => b.addAll(values.take(3).toList().asMap())),
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
                allValues: state.allValues
                    .rebuild((b) => b.addAll(values.take(3).toList().asMap())),
                length: 3,
              ),
            ],
          ),
        ],
      );
    });

    test('Reverse fetching', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (section) async* {
            print(section);
            if (section == IterableSection(10, 10)) {
              yield IterableFetchEvent.empty();
            } else {
              yield IterableFetchEvent.fetched(
                  values.skip(section.startAt).take(section.length));
            }
          },
        )..listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state,
              state,
              state = state.toUpdating(),
              state = state.toUpdated(length: 10),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(
                        10, (index) => MapEntry(index, values[index])))),
                length: 10,
              ),
            ],
          ),
        ],
      );
    });

    test('Fetch two page and reverse fetching for two page', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $>(
          fetcher: (section) async* {
            yield IterableFetchEvent.fetched(
                values.skip(section.startAt).take(section.length));
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
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(
                        10, (index) => MapEntry(index, values[index])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10,
                        (index) => MapEntry(index + 10, values[index + 10])))),
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
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10,
                        (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(
                        10, (index) => MapEntry(index, values[index])))),
              ),
            ],
          ),
        ],
      );
    });

    test('Update previous page', () async {
      IterableCubitState<int, $> state = IterableCubitIdle<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
      );
      await runCubitTest<MultiCubit<int, $>, IterableCubitState<int, $>>(
        wait: Duration(milliseconds: 700),
        build: () => MultiCubit<int, $>(
          fetcher: (section) async* {
            print(section);
            if (section == IterableSection(10, 10)) {
              yield IterableFetchEvent.empty();
            } else {
              yield IterableFetchEvent.fetched(
                  values.skip(section.startAt).take(section.length));
              await Future.delayed(Duration(seconds: 1));
              yield IterableFetchEvent.fetched(
                  values.skip(section.startAt + 20).take(section.length + 20));
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
                allValues: state.allValues.rebuild(
                  (b) => b.addEntries(List.generate(
                      10, (index) => MapEntry(index, values[index]))),
                ),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdating(),
              state = state.toUpdated(length: 10),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(
                        10, (index) => MapEntry(index, values[index + 20])))),
              ),
            ],
          ),
        ],
      );
    });
  });
}
