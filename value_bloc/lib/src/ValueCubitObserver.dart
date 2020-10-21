import '../value_bloc.dart';

class ValueCubitObserver {
  static bool isEnabledPrintMethodIgnored = false;

  static ValueCubitObserver instance = ValueCubitObserver();

  void methodIgnored(ValueState<dynamic> state, String nameMethod) {
    if (!ValueCubitObserver.isEnabledPrintMethodIgnored) return;
    print('method:$nameMethod,state:$state');
    print(StackTrace.current);
  }
}
