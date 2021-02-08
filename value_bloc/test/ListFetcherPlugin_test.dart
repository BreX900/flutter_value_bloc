import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/value_bloc.dart';

void main() {
  group('ListFetcherPlugin tests', () {
    final ListFetcherPlugin fetcher = SimpleListFetcherPlugin();

    test('Add scheme before an exist scheme', () {
      final schemes = BuiltSet<IterableSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([IterableSection(5, 10)]);
      });
      final res = fetcher.update(schemes, IterableSection(0, 10));
      expect(res, BuiltSet<IterableSection>([IterableSection(0, 5), IterableSection(5, 10)]));
    });

    test('Add scheme before exist scheme with similar scheme', () {
      final schemes = BuiltSet<IterableSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([IterableSection(5, 10)]);
      });
      final res = fetcher.update(schemes, IterableSection(0, 15));
      expect(
        res,
        BuiltSet<IterableSection>([
          IterableSection(0, 5),
          IterableSection(5, 10),
        ]),
      );
    });

    test('Add scheme before exist scheme', () {
      final schemes = BuiltSet<IterableSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([IterableSection(20, 10), IterableSection(30, 10)]);
      });
      final res = fetcher.update(schemes, IterableSection(10, 10));
      expect(
        res,
        BuiltSet<IterableSection>([
          IterableSection(10, 10),
          IterableSection(20, 10),
          IterableSection(30, 10),
        ]),
      );
    });

    test('Add scheme before and after exist scheme', () {
      final schemes = BuiltSet<IterableSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([IterableSection(5, 5)]);
      });
      final res = fetcher.update(schemes, IterableSection(0, 15));
      expect(
        res,
        BuiltSet<IterableSection>([
          IterableSection(0, 5),
          IterableSection(5, 5),
          IterableSection(10, 5),
        ]),
      );
    });

    test('Add schemes in separate locations', () {
      final schemes = BuiltSet<IterableSection>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([IterableSection(15, 5)]);
      });
      final beforeRes = fetcher.update(schemes, IterableSection(5, 5));
      expect(
        beforeRes,
        BuiltSet<IterableSection>([
          IterableSection(5, 5),
          IterableSection(15, 5),
        ]),
      );
      final afterRes = fetcher.update(beforeRes, IterableSection(25, 5));
      expect(
        afterRes,
        BuiltSet<IterableSection>([
          IterableSection(5, 5),
          IterableSection(15, 5),
          IterableSection(25, 5),
        ]),
      );
    });
  });
}
