import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'LoadState.dart';

class LoadCubit<ExtraData> extends Cubit<LoadCubitState<ExtraData>> {
  Loader _loader;

  LoadCubit({
    Loader loader,
  })  : _loader = loader,
        super(LoadCubitIdle());

  void updateLoader({@required Loader loader}) {
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
  /// Attention reload the data if it has already been uploaded
  ///
  /// See also [load]
  void reLoad() async {
    await Future.delayed(const Duration());
    if (state is LoadCubitLoading<ExtraData>) return;
    emit(state.toLoading());
    _loader();
  }

  void emitLoading({@required double progress, ExtraData extraData}) async {
    await Future.delayed(const Duration());
    emit(state.toLoading(progress: progress, extraData: extraData));
  }

  void emitLoadFailed({Object failure, ExtraData extraData}) async {
    await Future.delayed(const Duration());
    emit(state.toFailed(failure: failure, extraData: extraData));
  }

  void emitLoaded() async {
    await Future.delayed(const Duration());
    emit(state.toLoaded());
  }
}
