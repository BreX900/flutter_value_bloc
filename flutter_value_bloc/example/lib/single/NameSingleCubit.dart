import 'package:flutter_value_bloc/flutter_value_bloc.dart';

class SingleNameCubit extends ValueCubit<String, Object> {
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
