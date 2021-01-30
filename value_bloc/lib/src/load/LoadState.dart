part of 'LoadCubit.dart';

typedef Loader = void Function();

abstract class LoadCubitState<Data> with EquatableMixin {
  LoadCubitState<Data> toLoading({double progress = 0.0, Data data}) {
    return LoadCubitLoading(progress: progress, data: data);
  }

  LoadCubitState<Data> toFailed({Object failure, Data data}) {
    return LoadCubitFailed(failure: failure, data: data);
  }

  LoadCubitState<Data> toLoaded() {
    return LoadCubitLoaded();
  }
}

class LoadCubitLoading<Data> extends LoadCubitState<Data> {
  final double progress;
  final Data data;

  LoadCubitLoading({this.progress = 0, this.data});

  @override
  List<Object> get props => [progress, data];
}

class LoadCubitFailed<Data> extends LoadCubitState<Data> {
  final Object failure;
  final Data data;

  LoadCubitFailed({this.failure, this.data});

  @override
  List<Object> get props => [failure, data];
}

class LoadCubitLoaded<Data> extends LoadCubitState<Data> {
  @override
  List<Object> get props => [];
}
