import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'LoadState.dart';

class LoadCubit<ExtraData> extends Cubit<LoadCubitState<ExtraData>> {
  Loader _loader;

  LoadCubit({
    Loader loader,
  }) : _loader = loader, super(LoadCubitIdle());

  void applyLoader({@required Loader loader}) {
    _loader = loader;
  }

  void load() {
    emit(state.toLoading());
    _loader();
  }

  void emitLoading({@required double progress, ExtraData extraData}) {
    emit(state.toLoading(progress: progress, extraData: extraData));
  }

  void emitLoadFailed({Object failure, ExtraData extraData}) {
    emit(state.toFailed(failure: failure, extraData: extraData));
  }

  void emitLoaded() {
    emit(state.toLoaded());
  }
}
