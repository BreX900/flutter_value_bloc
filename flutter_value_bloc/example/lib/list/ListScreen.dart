import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class ListScreenCubit extends ScreenCubit<int> {
  final personsCubit = MultiCubit<Person, int>();

  ListScreenCubit() : super(0) {
    personsCubit.applyFetcher(fetcher: (selection) async* {
      await Future.delayed(Duration(seconds: 2));
      if (selection.startAt >= 30) {
        yield EmptyFetchEvent();
      } else {
        final persons = personList.skip(selection.endAt).take(selection.length);
        yield IterableFetchedEvent(persons);
      }
    });
  }
}

class ListScreen extends StatelessWidget {
  const ListScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListScreenCubit>(
      create: (context) => ListScreenCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('List with ListValueCubit'),
        ),
        body: ScreenCubitConsumer<ListScreenCubit, int>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<ListScreenCubit>(context);

            return ListViewCubitBuilder<Person>(
              iterableCubit: screenCubit.personsCubit,
              // plugin: RefresherValueCubitPlugin(enablePullUp: true),
              builder: (context, state) {
                return ListView.separated(
                  itemCount: state.values.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final person = state.values[index];

                    return ListTile(
                      title: Text('${person.name} ${person.surname}'),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
