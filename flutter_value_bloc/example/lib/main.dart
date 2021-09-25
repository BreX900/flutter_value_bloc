import 'package:example/list/list_screen.dart';
import 'package:example/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

void main() {
  Bloc.observer = _BlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewsProvider.value(
      value: const Views(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = dumpErrorToConsole;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ElevatedButton(
            //   onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            //     builder: (context) => const SingleScreen(),
            //   )),
            //   child: const Text('SingleValueCubit'),
            // ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ListScreen(),
              )),
              child: const Text('ListValueCubit in List'),
            ),
            // ElevatedButton(
            //   onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            //     builder: (context) => const TableScreen(),
            //   )),
            //   child: const Text('ListValueCubit in Table'),
            // ),
          ],
        ),
      ),
    );
  }
}

class _BlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Bloc) return;
    debugPrint('Bloc#Change#${bloc.runtimeType}:\n'
        ' currentState: ${change.currentState}\n'
        ' nextState: ${change.nextState}\n');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('Bloc#Transation#${bloc.runtimeType}:\n'
        ' currentState${transition.currentState}\n'
        ' event: ${transition.event}\n'
        ' nextState: ${transition.nextState}\n');
  }
}
