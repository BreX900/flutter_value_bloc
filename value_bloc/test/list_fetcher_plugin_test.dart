import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/value_bloc.dart';

void main() {
  group('ListFetcherPlugin tests', () {
    final ListFetcherPlugin fetcher = ContinuousListFetcherPlugin();

    test('Add scheme before an exist scheme', () {
      final schemes = BuiltSet<PageOffset>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([PageOffset(5, 10)]);
      });
      final res = fetcher.addTo(schemes, PageOffset(0, 10));
      expect(res, BuiltSet<PageOffset>([PageOffset(0, 5), PageOffset(5, 10)]));
    });

    test('Add scheme before exist scheme with similar scheme', () {
      final schemes = BuiltSet<PageOffset>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([PageOffset(5, 10)]);
      });
      final res = fetcher.addTo(schemes, PageOffset(0, 15));
      expect(
        res,
        BuiltSet<PageOffset>([
          PageOffset(0, 5),
          PageOffset(5, 10),
        ]),
      );
    });

    test('Add scheme before exist scheme', () {
      final schemes = BuiltSet<PageOffset>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([PageOffset(20, 10), PageOffset(30, 10)]);
      });
      final res = fetcher.addTo(schemes, PageOffset(10, 10));
      expect(
        res,
        BuiltSet<PageOffset>([
          PageOffset(10, 10),
          PageOffset(20, 10),
          PageOffset(30, 10),
        ]),
      );
    });

    test('Add scheme before and after exist scheme', () {
      final schemes = BuiltSet<PageOffset>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([PageOffset(5, 5)]);
      });
      final res = fetcher.addTo(schemes, PageOffset(0, 15));
      expect(
        res,
        BuiltSet<PageOffset>([
          PageOffset(0, 5),
          PageOffset(5, 5),
          PageOffset(10, 5),
        ]),
      );
    });

    test('Add schemes in separate locations', () {
      final schemes = BuiltSet<PageOffset>.build((b) {
        b
          ..withBase(() => HashSet())
          ..addAll([PageOffset(15, 5)]);
      });
      final beforeRes = fetcher.addTo(schemes, PageOffset(5, 5));
      expect(
        beforeRes,
        BuiltSet<PageOffset>([
          PageOffset(5, 5),
          PageOffset(15, 5),
        ]),
      );
      final afterRes = fetcher.addTo(beforeRes, PageOffset(25, 5));
      expect(
        afterRes,
        BuiltSet<PageOffset>([
          PageOffset(5, 5),
          PageOffset(15, 5),
          PageOffset(25, 5),
        ]),
      );
    });
  });
}
