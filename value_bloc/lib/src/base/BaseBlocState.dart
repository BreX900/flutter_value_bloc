import 'package:built_value/built_value.dart';
import 'package:value_bloc/src/status.dart';

part 'BaseBlocState.g.dart';

@BuiltValue(instantiable: false)
abstract class BaseBlocState<Filter> {
  LoadStatusValueBloc get loadStatus;
  FetchStatusValueBloc get fetchStatus;
  bool get refreshStatus;

  @nullable
  Filter get filter;

  static void finalizeBuilder(BaseBlocStateBuilder b) {
    if (b.fetchStatus.isFetching && b.loadStatus.isIdle) {
      b.loadStatus = LoadStatusValueBloc.loading;
    }
  }

  BaseBlocState<Filter> rebuild(
      covariant Function(BaseBlocStateBuilder<Filter> b) updates);
}

abstract class BaseBlocStateBuilder<Filter> {
  LoadStatusValueBloc loadStatus;
  FetchStatusValueBloc fetchStatus;
  bool refreshStatus;

  Filter filter;
}
