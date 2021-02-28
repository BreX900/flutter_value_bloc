import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class SingleScreenCubit extends ModularCubit<int> with CloseCubitModule, LoadCubitModule {
  final personCubit = SingleCubit<Person, int, int>();

  SingleScreenCubit() : super(0) {
    personCubit
      ..applyFetcher(fetcher: (filter) async* {
        await Future.delayed(Duration(seconds: 2));
        yield ObjectFetchedEvent(personList[0]);
      })
      ..addToContainer(this);
  }

  @override
  void onLoading() async {
    await Future.delayed(Duration(seconds: 1));
    // initialize ScreenCubit
    emitLoaded();
  }
}

class SingleScreen extends StatelessWidget {
  const SingleScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SingleScreenCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: ModularViewCubitBuilder<SingleScreenCubit, int>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<SingleScreenCubit>(context);

            return ViewCubitBuilder<Person>(
              objectCubit: screenCubit.personCubit,
              builder: (context, person) {
                return Text(person?.name ?? '');
              },
            );
          },
        ),
      ),
    );
  }
}
