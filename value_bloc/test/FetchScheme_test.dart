import 'package:test/test.dart';
import 'package:value_bloc/src/internalUtils.dart';

void main() {
  group('FetchScheme tests', () {
    test('P1', () {
      final res = IterableSection(0, 15).mergeWith(startAt: IterableSection(0, 5).endAt);

      expect(
        res,
        IterableSection(5, 10),
      );
    });
  });
}
