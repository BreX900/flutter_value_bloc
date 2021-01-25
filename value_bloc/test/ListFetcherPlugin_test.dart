import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/multi/MultiCubit.dart';

void main() {
  group('ListFetcherPlugin tests', () {
    final ListFetcherPlugin fetcher = SimpleListFetcherPlugin();

    test('Add scheme before an exist scheme', () {
      final schemes = BuiltSet<ListSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([ListSection(5, 10)]);
      });
      final res = fetcher.update(schemes, ListSection(0, 10));
      expect(res, BuiltSet<ListSection>([ListSection(0, 5), ListSection(5, 10)]));
    });

    test('Add scheme before exist scheme with similar scheme', () {
      final schemes = BuiltSet<ListSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([ListSection(5, 10)]);
      });
      final res = fetcher.update(schemes, ListSection(0, 15));
      expect(
        res,
        BuiltSet<ListSection>([
          ListSection(0, 5),
          ListSection(5, 10),
        ]),
      );
    });

    test('Add scheme before and after exist scheme', () {
      final schemes = BuiltSet<ListSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([ListSection(5, 5)]);
      });
      final res = fetcher.update(schemes, ListSection(0, 15));
      expect(
        res,
        BuiltSet<ListSection>([
          ListSection(0, 5),
          ListSection(5, 5),
          ListSection(10, 5),
        ]),
      );
    });

    test('Add schemes in separate locations', () {
      final schemes = BuiltSet<ListSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([ListSection(15, 5)]);
      });
      final beforeRes = fetcher.update(schemes, ListSection(5, 5));
      expect(
        beforeRes,
        BuiltSet<ListSection>([
          ListSection(5, 5),
          ListSection(15, 5),
        ]),
      );
      final afterRes = fetcher.update(beforeRes, ListSection(25, 5));
      expect(
        afterRes,
        BuiltSet<ListSection>([
          ListSection(5, 5),
          ListSection(15, 5),
          ListSection(25, 5),
        ]),
      );
    });
  });
}
