import 'package:value_bloc/value_bloc.dart';

class HomeViewState {}

class HomeView extends ViewCubit<HomeViewState, Object> {
  HomeView(HomeViewState state) : super(state);
  @override
  void onLoading() {}
}

void main() {}
