class ValueCubitObserver {
  static ValueCubitObserver instance = ValueCubitObserver();

  void methodIgnored(Object state, String nameMethod) {
    print('method:$nameMethod,state:$state');
  }
}