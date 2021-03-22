import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class TableScreenCubit extends ModularCubit<int> with LoadCubitModule, CloserCubitModule {
  final personsCubit = MultiCubit<Person, int, int>();

  TableScreenCubit() : super(0) {
    personsCubit
      ..updateFetcher(fetcher: (section, filter) async* {
        // Fetch values on database
        print('Fetching... ${section}');
        await Future.delayed(Duration(seconds: 1));
        if (section.startAt > 35) {
          yield EmptyFetchEvent();
        } else {
          final persons = personList.skip(section.startAt).take(section.length);
          yield IterableFetchedEvent(persons);
        }
      })
      ..addToCloserCubit(this);
  }

  @override
  void onLoading() async {
    await Future.delayed(Duration(seconds: 1));
    // initialize ScreenCubit
    emitLoaded();
  }
}

class TableScreen extends StatelessWidget {
  const TableScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TableScreenCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Table with ListValueCubit'),
        ),
        body: ModularViewCubitBuilder<TableScreenCubit, int>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<TableScreenCubit>(context);

            return SingleChildScrollView(
              child: PaginatedDataTableCubitBuilder<Person>(
                iterableCubit: screenCubit.personsCubit,
                header: Text('Names'),
                actions: [
                  IconButton(
                    onPressed: () => screenCubit.personsCubit.clear(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Surname')),
                ],
                builder: (person) {
                  if (person == null) {
                    return null;
                  }

                  return DataRow(cells: [
                    DataCell(Text(person.name)),
                    DataCell(Text(person.surname)),
                  ]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
