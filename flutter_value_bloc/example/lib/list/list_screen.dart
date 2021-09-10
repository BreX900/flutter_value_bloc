import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/flutter_value_bloc_3.dart';

class CreatePersonDataBloc extends CreateDataBloc<String, Person> {}

class PersonsBloc extends ListBloc<String, Person> {
  final syncBus = SyncEventBus<Person>();

  PersonsBloc() : super() {
    syncBus
        .streamFromOther([this])
        .transform(const ListBlocSyncer<String, Person>())
        .listen(add)
        .addToDisposer(this);
  }

  void create() => add(CreatePersonDataBloc());

  @override
  Stream<DataBlocEmission<String, Person>> mapActionToEmission(
    DataBlocAction<String, Person> event,
  ) async* {
    if (event is CreatePersonDataBloc) {
      await Future.delayed(const Duration(seconds: 3));
      yield event.toAddValue(Person.next());
      return;
    }
    if (event is ReadDataBloc<String, Person>) {
      await Future.delayed(const Duration(seconds: 1));
      yield event.toEmitList(personList.take(10).toBuiltList());
      return;
    }
  }
}

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonsBloc>(
      create: (context) => PersonsBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('List with ListValueCubit'),
          actions: [
            ActionDataBlocBuilder<PersonsBloc, String, BuiltList<Person>>(
              builder: (context, state, canPerform) {
                return PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: ListTile(
                          enabled: canPerform,
                          onTap: () =>
                              context.read<PersonsBloc>().syncBus.emitCreate(this, Person.next()),
                          title: const Text('Sync Create'),
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          enabled: canPerform,
                          onTap: () => context.read<PersonsBloc>().syncBus.emitInvalidate(this),
                          title: const Text('Sync invalidate'),
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          enabled: canPerform,
                          onTap: () => context.read<PersonsBloc>().create(),
                          title: const Text('Create'),
                        ),
                      ),
                    ];
                  },
                );
              },
            ),
          ],
        ),
        body: ViewDataBlocBuilder<PersonsBloc, String, BuiltList<Person>>(
          builder: (context, persons) {
            return RefreshGroupDataBlocBuilder(
              dataBlocs: [context.read<PersonsBloc>()],
              child: ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index];

                  return ListTile(
                    title: Text('${person.name} ${person.surname}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
