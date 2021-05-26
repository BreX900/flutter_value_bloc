import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class DataCubitBuilder<
    TDataBloc extends DataCubit<DataState<TFailure, TSuccess>, TFailure, TSuccess>,
    TFailure,
    TSuccess> extends BlocBuilder<TDataBloc, DataState<TFailure, TSuccess>> {
  DataCubitBuilder({
    Key? key,
    TDataBloc? bloc,
    BlocBuilderCondition<DataState<TFailure, TSuccess>>? buildWhen,
    required BlocWidgetBuilder<DataState<TFailure, TSuccess>> builder,
  }) : super(
          key: key,
          bloc: bloc,
          buildWhen: buildWhen,
          builder: builder,
        );
}

class MultiDataCubitBuilder<TDataBloc extends MultiDataCubit<TFailure, TSuccess>, TFailure,
    TSuccess> extends BlocBuilder<TDataBloc, MultiDataState<TFailure, TSuccess>> {
  MultiDataCubitBuilder({
    Key? key,
    TDataBloc? bloc,
    BlocBuilderCondition<MultiDataState<TFailure, TSuccess>>? buildWhen,
    required BlocWidgetBuilder<MultiDataState<TFailure, TSuccess>> builder,
  }) : super(
          key: key,
          bloc: bloc,
          buildWhen: buildWhen,
          builder: builder,
        );
}
