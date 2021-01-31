part of 'LoadCubit.dart';

typedef Loader = void Function();

abstract class LoadCubitState with EquatableMixin {
  LoadCubitState toLoading({double progress = 0.0, Object data}) {
    return LoadCubitLoading(progress: progress, data: data);
  }

  LoadCubitState toFailed({Object failure, Object data}) {
    return LoadCubitFailed(failure: failure, data: data);
  }

  LoadCubitState toLoaded() {
    return LoadCubitLoaded();
  }
}

class LoadCubitLoading extends LoadCubitState {
  final double progress;
  final Object data;

  LoadCubitLoading({this.progress = 0, this.data});

  @override
  List<Object> get props => [progress, data];
}

class LoadCubitFailed extends LoadCubitState {
  final Object failure;
  final Object data;

  LoadCubitFailed({this.failure, this.data});

  @override
  List<Object> get props => [failure, data];
}

class LoadCubitLoaded<Data> extends LoadCubitState {
  @override
  List<Object> get props => [];
}
