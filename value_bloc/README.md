<# value_bloc

| GitHub | pub.dev |
| --- | --- |
| [value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/value_bloc) | [value_bloc](https://pub.dev/packages/value_bloc) |
| [flutter_value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/flutter_value_bloc) | [flutter_value_bloc](https://pub.dev/packages/flutter_value_bloc) |



## Getting Started
You can find many cubits that are right for you.

### Modular cubits

You can integrate modules into your cubits

#### LoadCubitModule
For example you can mix `LoadCubitModule` to integrate a load function
```dart
class MyCubit extends ModularCubit<State> with LoadCubitModule {
  void onLoading() {
    // write your code for initializing bloc
    emitLoading();
  }
}
```


#### Local Value/s cubits
Cubit as: `ValueCubit`, `ListCubit`, `SetCubit` is recommended to use as described below
```dart
class MyCubit extends Cubit<State> {
  final userCubit = ValueCubit<User, Object>();
  
  MyCubit() {
    userCubit.updateValue(value: User('Piero'));
  }
}
```

#### Fetch Value/s cubits

Cubist as: `SingleCubit` and `MultiCubit` is recommended to use as described below
```dart
class MyCubit extends Cubit<State> {
  final userCubit = SingleCubit<User, Filter, Object>();
  
  MyCubit() {
    userCubit.fetcher(fetcher: _fetcher);
  }
  
  _fetcher(Filter filter) async* {
    if (filter == Filter.empty) {
      yield SingleFetchEvent.empty();
    } else {
      yield SingleFetchEvent.fetched(User('Piero'));
    }
  }
}
```
