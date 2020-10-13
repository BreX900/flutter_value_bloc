import 'package:example/list/ListNameCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class TableNameScreen extends StatelessWidget {
  const TableNameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListNameCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Table with ListValueCubit'),
        ),
        body: SingleChildScrollView(
          child: PaginatedTableListValueCubitBuilder<ListNameCubit, String, Object>(
            header: Text('Names'),
            columns: [DataColumn(label: Text('Name'))],
            builder: (name) => DataRow(cells: [DataCell(Text('$name'))]),
          ),
        ),
      ),
    );
  }
}
