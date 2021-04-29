part of 'LoadCubit.dart';

typedef Loader = void Function();

abstract class LoadCubitState<ExtraData> with EquatableMixin {
  final ExtraData? extraData;

  const LoadCubitState({required this.extraData});

  LoadCubitState<ExtraData> toLoading({double progress = 0.0}) {
    return LoadCubitLoading(progress: progress, extraData: extraData);
  }

  LoadCubitState<ExtraData> toFailed({Object? failure}) {
    return LoadCubitFailed(failure: failure, extraData: extraData);
  }

  LoadCubitState<ExtraData> toLoaded() {
    return LoadCubitLoaded(extraData: extraData);
  }

  @override
  List<Object?> get props => [extraData];
}

class LoadCubitIdle<ExtraData> extends LoadCubitState<ExtraData> {
  LoadCubitIdle({ExtraData? extraData}) : super(extraData: extraData);
}

class LoadCubitLoading<ExtraData> extends LoadCubitState<ExtraData> {
  final double progress;

  LoadCubitLoading({ExtraData? extraData, this.progress = 0}) : super(extraData: extraData);

  @override
  List<Object?> get props => super.props..add(progress);
}

class LoadCubitFailed<ExtraData> extends LoadCubitState<ExtraData> {
  final Object? failure;

  LoadCubitFailed({ExtraData? extraData, this.failure}) : super(extraData: extraData);

  @override
  List<Object?> get props => super.props..add(failure);
}

class LoadCubitLoaded<ExtraData> extends LoadCubitState<ExtraData> {
  LoadCubitLoaded({ExtraData? extraData}) : super(extraData: extraData);
}
