import 'package:example/entities/Person.dart';
import 'package:example/list/ListNameCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class TableScreen extends StatelessWidget {
  const TableScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListPersonCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Table with ListValueCubit'),
        ),
        body: SingleChildScrollView(
          child: PaginatedDataTableCubitBuilder<ListPersonCubit, Person, Object>(
            header: Text('Names'),
            columns: [DataColumn(label: Text('Name')), DataColumn(label: Text('Surname'))],
            builder: (person) {
              if (person == null)
                return DataRow(cells: [
                  DataCell.empty,
                  DataCell.empty,
                ]);

              return DataRow(cells: [
                DataCell(Text(person.name)),
                DataCell(Text(person.surname)),
              ]);
            },
          ),
        ),
      ),
    );
  }
}
