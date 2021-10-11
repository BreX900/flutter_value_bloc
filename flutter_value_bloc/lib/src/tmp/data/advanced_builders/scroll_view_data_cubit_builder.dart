// import 'package:flutter/material.dart';
// import 'package:flutter_value_bloc/flutter_value_bloc.dart';
// import 'package:flutter_value_bloc/src/data/single_data_cubit_listener.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:value_bloc/value_bloc.dart';
//
// class ScrollViewDataCubitBuilder<TDataCubit extends MapDataCubitBase<TFailure, TData>, TFailure,
//     TData> extends StatefulWidget {
//   final TDataCubit mapDataCubit;
//   final bool isPullDownEnabled;
//   final bool isPullUpEnabled;
//   final BlocWidgetBuilder<MultiDataState<TFailure, TData>> builder;
//
//   const ScrollViewDataCubitBuilder({
//     Key? key,
//     required this.mapDataCubit,
//     this.isPullDownEnabled = false,
//     this.isPullUpEnabled = false,
//     required this.builder,
//   }) : super(key: key);
//
//   @override
//   _ScrollViewDataCubitBuilderState<TDataCubit, TFailure, TData> createState() =>
//       _ScrollViewDataCubitBuilderState();
// }
//
// class _ScrollViewDataCubitBuilderState<TDataCubit extends MapDataCubitBase<TFailure, TData>,
//     TFailure, TData> extends State<ScrollViewDataCubitBuilder<TDataCubit, TFailure, TData>> {
//   late PageOffset _offset;
//   RefreshController? _controller;
//
//   PageOffset get initialOffset => PageOffset(0, 20);
//
//   @override
//   void initState() {
//     super.initState();
//     _offset = initialOffset;
//     _initCubit();
//     _initController();
//   }
//
//   @override
//   void didUpdateWidget(
//       covariant ScrollViewDataCubitBuilder<TDataCubit, TFailure, TData> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.mapDataCubit != oldWidget.mapDataCubit) {
//       _offset = initialOffset;
//       _initCubit();
//     }
//     if (widget.isPullDownEnabled != oldWidget.isPullDownEnabled) {
//       _initController();
//     }
//   }
//
//   void _initCubit() {
//     if (widget.mapDataCubit.state.status.isIdle) {
//       widget.mapDataCubit.read(_offset);
//     }
//   }
//
//   void _initController() {
//     if (widget.isPullDownEnabled || widget.isPullUpEnabled) {
//       _controller = RefreshController(
//         initialRefreshStatus: _resolveRefresh(widget.mapDataCubit.state),
//         initialLoadStatus: _resolveLoad(widget.mapDataCubit.state),
//       );
//     } else {
//       _controller = null;
//     }
//   }
//
//   RefreshStatus _resolveRefresh(MultiDataState<TFailure, TData> state) {
//     if (_controller!.headerStatus != RefreshStatus.refreshing) return _controller!.headerStatus!;
//
//     switch (state.status) {
//       case DataStatus.reading:
//         return RefreshStatus.refreshing;
//       case DataStatus.readFailed:
//         return RefreshStatus.failed;
//       case DataStatus.read:
//         return RefreshStatus.completed;
//       default:
//         return _controller!.headerStatus!;
//     }
//   }
//
//   LoadStatus _resolveLoad(MultiDataState<TFailure, TData> state) {
//     if (_controller!.footerStatus != LoadStatus.loading) return _controller!.footerStatus!;
//
//     switch (state.status) {
//       case DataStatus.reading:
//         return LoadStatus.loading;
//       case DataStatus.readFailed:
//         return LoadStatus.failed;
//       case DataStatus.read:
//         return state.isFull ? LoadStatus.noMore : LoadStatus.idle;
//       default:
//         return _controller!.footerStatus!;
//     }
//   }
//
//   void _refresh() {
//     _offset = initialOffset;
//     widget.mapDataCubit.read(_offset);
//   }
//
//   void _readNextPage() {
//     _offset = _offset.next();
//     widget.mapDataCubit.read(_offset);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiDataCubitListener<TDataCubit, TFailure, TData>(
//       dataCubit: widget.mapDataCubit,
//       onIdle: (context, state) => widget.mapDataCubit.read(_offset),
//       child: BlocBuilder<TDataCubit, MultiDataState<TFailure, TData>>(
//         bloc: widget.mapDataCubit,
//         builder: (context, state) {
//           var current = widget.builder(context, state);
//
//           if (_controller != null && state.hasData) {
//             current = SmartRefresher(
//               controller: _controller!,
//               enablePullDown: widget.isPullDownEnabled,
//               onRefresh: _refresh,
//               onLoading: _readNextPage,
//               child: current,
//             );
//           }
//
//           return current;
//         },
//       ),
//     );
//   }
// }
