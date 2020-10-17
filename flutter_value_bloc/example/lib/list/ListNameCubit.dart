import 'package:example/entities/Person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class ListPersonCubit extends ListValueCubit<Person, Object> {
  @override
  void onFetching(FetchScheme scheme) async {
    await Future.delayed(Duration(seconds: 2));
    print(scheme);
    emitFetched(scheme, personList.skip(scheme.offset).take(scheme.limit));
  }
}

class ListNameScreen extends StatelessWidget {
  const ListNameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
