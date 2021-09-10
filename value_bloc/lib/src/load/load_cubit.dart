import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'load_state.dart';

class LoadCubit<ExtraData> extends Cubit<LoadCubitState<ExtraData?>> {
  late Loader _loader;

  LoadCubit({
    Loader? loader,
  }) : super(LoadCubitIdle()) {
    if (loader != null) {
      _loader = loader;
    }
  }

  void updateLoader({required Loader loader}) {
    _loader = loader;
  }

  /// Calls the method to load the data
  /// Does not call it if it has already been loaded
  ///
  /// See also [reLoad]
  void load() async {
    await Future.delayed(const Duration());
    if (state is LoadCubitLoading<ExtraData> || state is LoadCubitLoaded<ExtraData>) return;
    emit(state.toLoading());
    _loader();
  }

  /// Calls the method to re load the data
  /// Attention reload the data even if it has already been loaded
  ///
  /// See also [load]
  void reLoad() async {
    await Future.delayed(const Duration());
    if (state is LoadCubitLoading<ExtraData>) return;
    emit(state.toLoading());
    _loader();
  }

  /// Notify a new loading progress
  ///
  /// You can notify the progress using [progress]
  void emitLoading({required double progress}) async {
    await Future.delayed(const Duration());
    emit(state.toLoading(progress: progress));
  }

  /// Notification that the upload is unsuccessful
  ///
  /// You can report the error using [failure]
  void emitLoadFailed({Object? failure}) async {
    await Future.delayed(const Duration());
    emit(state.toFailed(failure: failure));
  }

  /// Notification that the upload was completed successfully
  void emitLoaded() async {
    await Future.delayed(const Duration());
    emit(state.toLoaded());
  }
}
