import 'package:example/list/ListScreen.dart';
import 'package:example/list/TableScreen.dart';
import 'package:example/single/SingleValueScreen.dart';
import 'package:example/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

void main() {
  runApp(MyApp());
}

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = dumpErrorToConsole;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SingleScreen(),
              )),
              child: Text('SingleValueCubit'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ListScreen(),
              )),
              child: Text('ListValueCubit in List'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TableScreen(),
              )),
              child: Text('ListValueCubit in Table'),
            ),
          ],
        ),
      ),
    );
  }
}
