import 'package:value_bloc/value_bloc.dart';

class ValueCubitObserver {
  static ValueCubitObserver instance = ValueCubitObserver();

  void methodIgnored(ValueState<dynamic> state, String nameMethod) {
    print('method:$nameMethod,state:$state');
    print(StackTrace.current);
  }
}
