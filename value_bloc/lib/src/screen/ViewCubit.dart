import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:value_bloc/src/load/LoadCubit.dart';

mixin ScreenCubitMixin<State, LoadCubitData> on Cubit<State> {
  final _viewCubits = <Cubit>[];

  LoadCubit<LoadCubitData> get loadCubit;

  void addViewCubit({@required Cubit viewCubit}) {
    _viewCubits.add(viewCubit);
  }

  void addViewCubits({@required Iterable<Cubit> viewCubits}) {
    _viewCubits.addAll(viewCubits);
  }

  void emitLoading({@required double progress, LoadCubitData data}) {
    loadCubit.notifyProgress(progress: progress, data: data);
  }

  void emitLoadFailed({Object failure, LoadCubitData data}) {
    loadCubit.notifyFailure(failure: failure, data: data);
  }

  void emitLoaded() => loadCubit.notifySuccess();

  @override
  Future<void> close() async {
    await Future.wait(_viewCubits.map((c) => c.close()));
    return super.close();
  }
}

class ScreenCubit<State, LoadCubitData> extends Cubit<State>
    with ScreenCubitMixin<State, LoadCubitData> {
  @override
  final LoadCubit<LoadCubitData> loadCubit;

  ScreenCubit(
    State state, {
    bool isLoading = false,
  })  : loadCubit = LoadCubit(isLoading: isLoading),
        super(state) {
    if (isLoading) onLoading();
  }

  void onLoading() {}
}
