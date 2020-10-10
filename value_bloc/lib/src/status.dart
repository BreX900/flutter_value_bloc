// part of '../value_bloc.dart';

enum LoadStatusValueBloc {
  /// The bloc required load before fetching
  idle,

  /// The bloc is performing the loading
  loading,

  /// The bloc is already loaded
  loaded,
}
enum FetchStatusValueBloc { idle, fetching, fetched }

extension LoadStatusValueBlocExtension on LoadStatusValueBloc {
  bool get isIdle => this == LoadStatusValueBloc.idle;
  bool get isLoading => this == LoadStatusValueBloc.loading;
  bool get isLoaded => this == LoadStatusValueBloc.loaded;
}

extension FetchStatusValueBlocExtension on FetchStatusValueBloc {
  bool get isIdle => this == FetchStatusValueBloc.idle;
  bool get isFetching => this == FetchStatusValueBloc.fetching;
  bool get isFetched => this == FetchStatusValueBloc.fetched;
}
