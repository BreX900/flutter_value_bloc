import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'LoadState.dart';

class LoadCubit<Data> extends Cubit<LoadCubitState<Data>> {
  LoadCubit({bool isLoading = true}) : super(isLoading ? LoadCubitLoading() : LoadCubitLoaded());

  void load({@required Loader loader}) {
    emit(state.toLoading());
    loader();
  }

  void notifyProgress({@required double progress, Data data}) {
    emit(state.toLoading(progress: progress, data: data));
  }

  void notifyFailure({Object failure, Data data}) {
    emit(state.toFailed(failure: failure, data: data));
  }

  void notifySuccess() {
    emit(state.toLoaded());
  }
}
