part of 'LoadCubit.dart';

typedef Loader = void Function();

abstract class LoadState<Data> with EquatableMixin {
  LoadState<Data> toLoading({double progress = 0.0, Data data}) {
    return LoadCubitLoading(progress: progress, data: data);
  }

  LoadState<Data> toFailed({Object failure, Data data}) {
    return LoadCubitFailed(failure: failure, data: data);
  }

  LoadState<Data> toLoaded() {
    return LoadCubitLoaded();
  }
}

class LoadCubitLoading<Data> extends LoadState<Data> {
  final double progress;
  final Data data;

  LoadCubitLoading({this.progress = 0, this.data});

  @override
  List<Object> get props => [progress, data];
}

class LoadCubitFailed<Data> extends LoadState<Data> {
  final Object failure;
  final Data data;

  LoadCubitFailed({this.failure, this.data});

  @override
  List<Object> get props => [failure, data];
}

class LoadCubitLoaded<Data> extends LoadState<Data> {
  @override
  List<Object> get props => [];
}
