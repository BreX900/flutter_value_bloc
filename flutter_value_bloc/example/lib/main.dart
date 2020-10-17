import 'package:example/list/TableNameScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

import 'single/SingleValueScreen.dart';
import 'utility.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDataProvider.value(
      value: ViewData(),
      child: MaterialApp(
        home: HomeScreen(),
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
                builder: (context) => SingleNameScreen(),
              )),
              child: Text('SingleValueCubit'),
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
