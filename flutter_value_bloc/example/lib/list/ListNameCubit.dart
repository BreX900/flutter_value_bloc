import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class ListNameCubit extends ListValueCubit<String, Object> {
  final values = List.generate(100, (index) => '$index Piero');

  @override
  void onFetching(FetchScheme scheme) async {
    await Future.delayed(Duration(seconds: 2));
    print(scheme);
    emitSuccessFetchedCount(
        scheme, values.skip(scheme.offset).take(scheme.limit), scheme.limit);
  }
}

class ListNameScreen extends StatelessWidget {
  const ListNameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
