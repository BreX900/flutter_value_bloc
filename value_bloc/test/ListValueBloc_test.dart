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

  group('Test IterableCubit with ContinuousListFetcherPlugin', () {
    test('Fetch on page and stop after four page is empty', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $, $>(
          fetcher: (selection, filter) async* {
            if (selection == IterableSection(30, 10)) {
              yield MultiFetchEvent.empty();
            } else {
              yield MultiFetchEvent.fetched(
                values.skip(selection.startAt).take(selection.length),
              );
            }
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(10).toList().asMap())),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10, (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(20, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10, (index) => MapEntry(index + 20, values[index + 20])))),
              ),
            ],
          ),
          CubitTest(
            // Fetch empty second page
            act: (c) => c.fetch(section: IterableSection(30, 10)),
            expect: [
              state = state.toUpdated(
                length: 30,
              ),
            ],
          ),
        ],
      );
    });

    test('Set length and fetch partial data', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $, $>(
          fetcher: (section, filter) async* {
            if (section == IterableSection(20, 10)) {
              yield MultiFetchEvent.fetched(values.skip(20).take(3));
            } else {
              yield MultiFetchEvent.fetched(values.skip(section.startAt).take(section.length));
            }
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(10).toList().asMap())),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10, (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(20, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(3, (index) => MapEntry(index + 20, values[index + 20])))),
                length: 23,
              ),
            ],
          ),
        ],
      );
    });

    test('When change the fetcher clean all values and refetch', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $, $>(
          fetcher: (selection, filter) async* {
            yield MultiFetchEvent.fetched(values.take(3));
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(
                allValues:
                    state.allValues.rebuild((b) => b.addAll(values.take(3).toList().asMap())),
                length: 3,
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.clear(),
            expect: [
              state = state.toUpdating(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
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

    test('Reverse fetching', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $, $>(
          fetcher: (section, filter) async* {
            print(section);
            if (section == IterableSection(10, 10)) {
              yield MultiFetchEvent.empty();
            } else {
              yield MultiFetchEvent.fetched(values.skip(section.startAt).take(section.length));
            }
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(length: 10),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) =>
                    b.addEntries(List.generate(10, (index) => MapEntry(index, values[index])))),
                length: 10,
              ),
            ],
          ),
        ],
      );
    });

    test('Fetch two page and reverse fetching for two page', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        build: () => MultiCubit<int, $, $>(
          fetcher: (section, filter) async* {
            yield MultiFetchEvent.fetched(values.skip(section.startAt).take(section.length));
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) =>
                    b.addEntries(List.generate(10, (index) => MapEntry(index, values[index])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10, (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.clear(),
            expect: [
              state = state.toUpdating(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b.addEntries(
                    List.generate(10, (index) => MapEntry(index + 10, values[index + 10])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) =>
                    b.addEntries(List.generate(10, (index) => MapEntry(index, values[index])))),
              ),
            ],
          ),
        ],
      );
    });

    test('Update previous page', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        wait: Duration(milliseconds: 700),
        build: () => MultiCubit<int, $, $>(
          fetcher: (section, filter) async* {
            print(section);
            if (section == IterableSection(10, 10)) {
              yield MultiFetchEvent.empty();
            } else {
              yield MultiFetchEvent.fetched(values.skip(section.startAt).take(section.length));
              await Future.delayed(Duration(seconds: 1));
              yield MultiFetchEvent.fetched(
                  values.skip(section.startAt + 20).take(section.length + 20));
            }
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) =>
                    b.addEntries(List.generate(10, (index) => MapEntry(index, values[index])))),
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(10, 10)),
            expect: [
              state = state.toUpdated(length: 10),
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) => b
                    .addEntries(List.generate(10, (index) => MapEntry(index, values[index + 20])))),
              ),
            ],
          ),
        ],
      );
    });

    test('Fetch and update filter', () async {
      IterableCubitState<int, $?> state = IterableCubitUpdating<int, $>(
        allValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
        extraData: null,
        oldAllValues: BuiltMap.build((b) => b.withBase(() => HashMap())),
      );
      await runCubitTest<MultiCubit<int, $, $>, IterableCubitState<int, $>>(
        wait: Duration(milliseconds: 700),
        build: () => MultiCubit<int, $, $>(
          fetcher: (section, filter) async* {
            if (filter == null) {
              yield MultiFetchEvent.fetched(values.skip(section.startAt).take(section.length),
                  total: 10);
            } else {
              yield MultiFetchEvent.fetched(values.skip(section.startAt).take(section.length),
                  total: 10);
            }
          },
        )..stream.listen(print),
        tests: [
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state,
              state,
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) =>
                    b.addEntries(List.generate(10, (index) => MapEntry(index, values[index])))),
                length: 10,
              ),
            ],
          ),
          CubitTest(
            act: (c) => c.applyFilter(filter: $()),
            expect: [
              state = state.toUpdating(),
            ],
          ),
          CubitTest(
            act: (c) => c.fetch(section: IterableSection(0, 10)),
            expect: [
              state = state.toUpdated(
                allValues: state.allValues.rebuild((b) =>
                    b.addEntries(List.generate(10, (index) => MapEntry(index, values[index])))),
                length: 10,
              ),
            ],
          ),
        ],
      );
    });
  });
}
