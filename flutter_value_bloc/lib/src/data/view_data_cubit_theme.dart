import 'package:flutter/material.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewDataCubitTheme<TFailure> {
  final bool canShowFailure;

  final Widget Function(
    BuildContext context,
    DataCubit<DataState<TFailure, dynamic>, TFailure, dynamic> dataCubit,
    DataState<TFailure, dynamic> state,
  ) progressBuilder;

  final Widget Function(
    BuildContext context,
    DataCubit<DataState<TFailure, dynamic>, TFailure, dynamic> dataCubit,
    DataState<TFailure, dynamic> state,
  ) failureBuilder;

  const ViewDataCubitTheme({
    this.canShowFailure = false,
    this.progressBuilder = buildProgress,
    this.failureBuilder = buildFailure,
  });

  static Widget buildProgress(
    BuildContext context,
    DataCubit<DataState<dynamic, dynamic>, dynamic, dynamic> dataCubit,
    DataState<dynamic, dynamic> state,
  ) {
    return Center(child: CircularProgressIndicator());
  }

  static Widget buildFailure(
    BuildContext context,
    DataCubit<DataState<dynamic, dynamic>, dynamic, dynamic> dataCubit,
    DataState<dynamic, dynamic> state,
  ) {
    return Center(child: Text('${state.failure}'));
  }

  ViewDataCubitTheme<TFailure> copyWith({
    bool? canShowFailure,
    Widget Function(
      BuildContext context,
      DataCubit<DataState<TFailure, dynamic>, TFailure, dynamic> dataCubit,
      DataState<TFailure, dynamic> state,
    )?
        progressBuilder,
    Widget Function(
      BuildContext context,
      DataCubit<DataState<TFailure, dynamic>, TFailure, dynamic> dataCubit,
      DataState<TFailure, dynamic> state,
    )?
        failureBuilder,
  }) {
    return ViewDataCubitTheme(
      canShowFailure: canShowFailure ?? this.canShowFailure,
      progressBuilder: progressBuilder ?? this.progressBuilder,
      failureBuilder: failureBuilder ?? this.failureBuilder,
    );
  }
}
