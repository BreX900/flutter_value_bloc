import 'package:test/test.dart';
import 'package:value_bloc/value_bloc.dart';

void main() {
  group('FetchScheme tests', () {
    test('P1', () {
      final res = PageOffset(0, 15).mergeWith(startAt: PageOffset(0, 5).endAt);

      expect(
        res,
        PageOffset(5, 10),
      );
    });
  });
}
