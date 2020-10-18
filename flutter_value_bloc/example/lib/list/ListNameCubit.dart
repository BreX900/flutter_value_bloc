import 'package:example/entities/Person.dart';
import 'package:value_bloc/value_bloc.dart';

class ListPersonCubit extends ListValueCubit<Person, Object> {
  @override
  void onFetching(FetchScheme scheme) async {
    await Future.delayed(Duration(seconds: 2));
    print(scheme);
    emitFetched(scheme, personList.skip(scheme.offset).take(scheme.limit));
  }
}
