// import 'dart:async';
//
// import 'package:flutter/widgets.dart';
// import 'package:flutter_value_bloc/flutter_value_bloc.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
//
// class RefreshPagedBuilder extends StatefulWidget {
//   final FutureOr<void> Function()? onRefresh;
//   final FutureOr<void> Function(int offset)? onLoadMore;
//
//   const RefreshPagedBuilder({
//     Key? key,
//     this.onRefresh,
//     this.onLoadMore,
//   }) : super(key: key);
//
//   @override
//   _RefreshPagedBuilderState createState() => _RefreshPagedBuilderState();
// }
//
// class _RefreshPagedBuilderState extends State<RefreshPagedBuilder> {
//   final _controller = RefreshController();
//
//   int _offset = 0;
//
//   void onRefresh() {
//     widget.onRefresh!();
//   }
//
//   void onLoadMore() async {
//     _offset += 10;
//     await widget.onLoadMore!(_offset);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<IndexedBloc2, MultiState>(
//       listener: (context, state) {
//         if (_controller.isLoading && !state.isUpdating) {
//           _controller.loadComplete();
//         }
//         if (_controller.isRefresh && !state.isUpdating) {
//           _controller.refreshCompleted();
//         }
//       },
//       builder: (context, state) {
//         return SmartRefresher(
//           controller: _controller,
//           onRefresh: state.isUpdating ? null : onRefresh,
//           onLoading: state.isUpdating ? null : onLoadMore,
//         );
//       },
//     );
//   }
// }
