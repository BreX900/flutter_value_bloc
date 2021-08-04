import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class ListScreenCubit extends ModularCubit<int> with BlocDisposer {
  final personsCubit = MultiCubit<Person, int, int>();

  ListScreenCubit() : super(0) {
    personsCubit
      ..updateFetcher(fetcher: (section, filter) async* {
        // Fetch values on database
        print('Fetching... ${section}');
        await Future.delayed(Duration(seconds: 1));
        if (section.startAt > 55) {
          yield EmptyFetchEvent();
        } else {
          final persons = personList.skip(section.startAt).take(section.length);
          yield IterableFetchedEvent(persons);
        }
      })
      ..addToDisposer(this);
  }
}

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListScreenCubit>(
      create: (context) => ListScreenCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('List with ListValueCubit'),
        ),
        body: ModularViewCubitBuilder<ListScreenCubit, int>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<ListScreenCubit>(context);

            return ListViewCubitBuilder<Person>(
              iterableCubit: screenCubit.personsCubit,
              valuesPerScroll: 20,
              isEnabledPullUp: true,
              builder: (context, person) {
                return ListTile(
                  title: Text('${person.name} ${person.surname}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
