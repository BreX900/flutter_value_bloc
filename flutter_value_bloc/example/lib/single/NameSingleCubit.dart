import 'package:value_bloc/value_bloc.dart';

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
