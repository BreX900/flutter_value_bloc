import 'package:test/test.dart';
import 'package:value_bloc/src/screen/Closeable.dart';

class TestCubit extends ModularCubit<int> with LoadCubitModule {
  TestCubit() : super(1);

  @override
  void onLoading() {
    emitLoaded();
  }
}

void main() {
  test('Test work?', () {
    final cubit = TestCubit();

    expect(cubit, TypeMatcher<LoadCubitModule>());
  });
}
