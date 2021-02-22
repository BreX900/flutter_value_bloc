import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class SingleScreenCubit extends Cubit<int> with CloseableModule, CubitContainer {
  final personCubit = SingleCubit<Person, int, int>();

  SingleScreenCubit() : super(0) {
    personCubit
      ..applyFetcher(fetcher: (filter) async* {
        await Future.delayed(Duration(seconds: 2));
        yield ObjectFetchedEvent(personList[0]);
      })
      ..addToContainer(this);
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
        body: ModularCubitConsumer<SingleScreenCubit, int>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<SingleScreenCubit>(context);

            return ViewCubitBuilder<ObjectCubitState<Person, int>>(
              dynamicCubit: screenCubit.personCubit,
              builder: (context, personState) {
                return Text(personState.value.name);
              },
            );
          },
        ),
      ),
    );
  }
}
