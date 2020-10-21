# flutter_value_bloc

| GitHub | pub.dev |
| --- | --- |
| [value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/value_bloc) | [value_bloc](https://pub.dev/packages/value_bloc) |
| [flutter_value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/flutter_value_bloc) | [flutter_value_bloc](https://pub.dev/packages/flutter_value_bloc) |


### Single Value example
Define a SingleValueCubit and use it for build a screen with single value
```dart
import 'package:value_bloc/value_bloc.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class SingleNameCubit extends SingleValueCubit<String, Object> {
  SingleNameCubit() : super(isLoading: true);

  @override
  void onLoading() async {
    await Future.delayed(Duration(seconds: 2));
    emitLoaded();
  }

  @override
  void onFetching() async {
    await Future.delayed(Duration(seconds: 1));
    emitFetched('Mario');
  }
}

class SingleScreen extends StatelessWidget {
  const SingleScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SingleNameCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SingleViewValueCubitBuilder<SingleNameCubit, String, Object>(
            plugin: RefresherValueCubitPlugin(),
            builder: (context, state) {
              return Text('${state.value}');
            },
          ),
        ),
      ),
    );
  }
}
```

### Values example 
Define a ListValueCubit and use it in list, grid, table or more widgets
```dart
import 'package:value_bloc/value_bloc.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class ListPersonCubit extends ListValueCubit<Person, Object> {
  @override
  void onFetching(FetchScheme scheme) async {
    await Future.delayed(Duration(seconds: 2));
    emitFetched(scheme, personList.skip(scheme.offset).take(scheme.limit));
  }
}
```

#### List Values example
```dart
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
```

### Paginated Table Example
```dart
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
          child: PaginatedTableListValueCubitBuilder<ListPersonCubit, Person, Object>(
            header: Text('Names'),
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Surname'))
            ],
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

```