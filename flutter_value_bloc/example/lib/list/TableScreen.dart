import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class TableScreenCubit extends ScreenCubit<int> {
  final personsCubit = MultiCubit<Person, int>();

  TableScreenCubit() : super(0, isLoading: true) {
    personsCubit.applyFetcher(fetcher: (selection) async* {
      // Fetch values on database

      await Future.delayed(Duration(seconds: 2));
      if (selection.startAt >= 30) {
        yield EmptyFetchEvent();
      } else {
        final persons = personList.skip(selection.endAt).take(selection.length);
        yield IterableFetchedEvent(persons);
      }
    });
  }

  @override
  void onLoading() async {
    await Future.delayed(Duration(seconds: 2));
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
        body: ScreenCubitConsumer<TableScreenCubit, int>(
          builder: (context, state) {
            final screenCubit = BlocProvider.of<TableScreenCubit>(context);

            return SingleChildScrollView(
              child: PaginatedDataTableCubitBuilder<Person>(
                iterableCubit: screenCubit.personsCubit,
                header: Text('Names'),
                actions: [
                  IconButton(
                    onPressed: () => screenCubit.personsCubit.reset(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
                columns: [DataColumn(label: Text('Name')), DataColumn(label: Text('Surname'))],
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
