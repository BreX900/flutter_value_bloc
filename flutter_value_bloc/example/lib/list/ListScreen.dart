import 'package:example/entities/Person.dart';
import 'package:example/list/ListNameCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListPersonCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('List with ListValueCubit'),
        ),
        body: ListViewValueCubitBuilder<ListPersonCubit, Person, Object>(
          plugin: RefresherValueCubitPlugin(),
          builder: (context, state) => ListView.separated(
            itemCount: state.values.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final person = state.values[index];

              return ListTile(
                title: Text('${person.name} ${person.surname}'),
              );
            },
          ),
        ),
      ),
    );
  }
}
