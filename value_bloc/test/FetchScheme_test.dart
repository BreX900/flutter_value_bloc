import 'package:test/test.dart';
import 'package:value_bloc/src/internalUtils.dart';

void main() {
  group('FetchScheme tests', () {
    test('P1', () {
      final res = ListSection(0, 15).mergeWith(startAt: ListSection(0, 5).endAt);

      expect(
        res,
        ListSection(5, 10),
      );
    });
  });
}
