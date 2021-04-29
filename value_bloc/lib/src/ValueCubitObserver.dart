import 'package:value_bloc/value_bloc.dart';

class ValueCubitObserver {
  static bool canPrintMethodIgnored = false;

  static ValueCubitObserver instance = ValueCubitObserver();

  void methodIgnored(Cubit<dynamic> cubit, String nameMethod) {
    if (!ValueCubitObserver.canPrintMethodIgnored) return;
    print('method:$nameMethod,state:${cubit.state}');
    print(StackTrace.current);
  }
}
