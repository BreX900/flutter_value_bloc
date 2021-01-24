import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:value_bloc/src/internalUtils.dart';
import 'package:value_bloc/src/multi/MultiCubit.dart';

void main() {
  group('ListFetcherPlugin tests', () {
    final ListFetcherPlugin fetcher = SimpleListFetcherPlugin();

    test('Add scheme before an exist scheme', () {
      final schemes = BuiltSet<FetchScheme>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([FetchScheme(5, 10)]);
      });
      final res = fetcher.update(schemes, FetchScheme(0, 10));
      expect(res, BuiltSet<FetchScheme>([FetchScheme(0, 5), FetchScheme(5, 10)]));
    });

    test('Add scheme before exist scheme with similar scheme', () {
      final schemes = BuiltSet<FetchScheme>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([FetchScheme(5, 10)]);
      });
      final res = fetcher.update(schemes, FetchScheme(0, 15));
      expect(
        res,
        BuiltSet<FetchScheme>([
          FetchScheme(0, 5),
          FetchScheme(5, 10),
        ]),
      );
    });

    test('Add scheme before and after exist scheme', () {
      final schemes = BuiltSet<FetchScheme>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([FetchScheme(5, 5)]);
      });
      final res = fetcher.update(schemes, FetchScheme(0, 15));
      expect(
        res,
        BuiltSet<FetchScheme>([
          FetchScheme(0, 5),
          FetchScheme(5, 5),
          FetchScheme(10, 5),
        ]),
      );
    });

    test('Add schemes in separate locations', () {
      final schemes = BuiltSet<FetchScheme>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([FetchScheme(15, 5)]);
      });
      final beforeRes = fetcher.update(schemes, FetchScheme(5, 5));
      expect(
        beforeRes,
        BuiltSet<FetchScheme>([
          FetchScheme(5, 5),
          FetchScheme(15, 5),
        ]),
      );
      final afterRes = fetcher.update(beforeRes, FetchScheme(25, 5));
      expect(
        afterRes,
        BuiltSet<FetchScheme>([
          FetchScheme(5, 5),
          FetchScheme(15, 5),
          FetchScheme(25, 5),
        ]),
      );
    });
  });
}
