# flutter_value_bloc

| GitHub | pub.dev |
| --- | --- |
| [value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/value_bloc) | [value_bloc](https://pub.dev/packages/value_bloc) |
| [flutter_value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/flutter_value_bloc) | [flutter_value_bloc](https://pub.dev/packages/flutter_value_bloc) |


## Getting Started
Create your ui in just a few taps

1. Wrap your `MaterialApp` with ViewsProviders to allow your Cubits to auto build loading, empty and error views
```dart
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewsProvider.value(
      value: Views(),
      child: CubitViewsProvider.value(
        value: CubitViews(),
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
  }
}
```

2. Define your own screen block
 - If you need to load data mix it with `LoadCubitModule`
 - If you need to close of the cubits you can mix `CloserCubitModule`
 - If you need to close of the stream subscriptions you can mix `CloserStreamSubscriptionModule`
```dart
class HomeScreenCubit extends ModularCubit<State> with LoadCubitModule {
  HomeScreenCubit();

  void onLoading() {
    // write your code for initializing bloc
    emitLoading();
  }
}
```

3. Build your screen view. 
 - Use ModularViewCubitBuilder to make the ui show the loader until the cubit is loaded or has failed to load
```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: ModularViewCubitBuilder<HomeScreenCubit, State>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<HomeScreenCubit>(context);

            return Text('...');
          },
        ),
      ),
    );
  }
}
```

4. I add other cubits such as:
 - `ValueCubit` Manage a single value
 - `SingleCubit` Fetch and manage a single value
 - `ListCubit` Manage a list values
 - `SetCubit` Manage a set values
 - `MultiCubit` Fetch and manage paginated values
```dart
class HomeScreenCubit extends ModularCubit<State> with LoadCubitModule, CloseCubitModule {
  final userCubit = ValueCubit<Person, Object>();

  HomeScreenCubit() {
    userCubit.addToCloserCubit(this);
  }
  
  void onLoading() async {
    // A very long operation
    await Future.delay(Duration(seconds: 1));
    
    userCubit.updateValue(User('Piero'));
    emitLoading();
  }
}
```

5. Build your graphics however you like
```dart
Widget build(BuildContext context) {
  return ViewCubitBuilder<Person>(
    objectCubit: screenCubit.userCubit,
    builder: (context, user) {
      return Text(user.name);
    },
  );
}
```