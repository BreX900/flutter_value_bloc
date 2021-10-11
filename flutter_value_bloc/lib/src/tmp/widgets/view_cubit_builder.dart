// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'package:flutter_value_bloc/src/views/view_provider.dart';
// import 'package:value_bloc/value_bloc.dart';
//
// class ViewCubitBuilder<S> extends StatefulWidget {
//   final DynamicCubit<S> dynamicCubit;
//   // final ViewValueCubitPlugin plugin;
//   // final BlocWidgetBuilder<FailedValueState> errorBuilder;
//   // final BlocWidgetBuilder<ProcessingValueState> loadingBuilder;
//   // final BlocWidgetBuilder<ValueState> emptyBuilder;
//   final BlocWidgetBuilder<S> builder;
//
//   const ViewCubitBuilder({
//     Key key,
//     // this.plugin,
//     @required this.dynamicCubit,
//     // this.errorBuilder,
//     // this.loadingBuilder,
//     // this.emptyBuilder,
//     @required this.builder,
//   }) : super(key: key);
//
//   @override
//   _ViewCubitBuilderState<S> createState() => _ViewCubitBuilderState<S>();
// }
//
// class _ViewCubitBuilderState<S> extends State<ViewCubitBuilder<S>> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Widget buildIterableState(BuildContext context, ViewData view, IterableCubitState state) {
//     if ((state is IterableCubitUpdating && state.length == null) || state is IterableCubitIdle) {
//       return view.loadingBuilder(context, 0.0);
//     } else if (state is IterableCubitUpdateFailed) {
//       return view.errorBuilder(context, state.failure);
//     } else if (state is IterableCubitUpdated && state.length == 0) {
//       return view.emptyBuilder(context);
//     }
//     return null;
//   }
//
//   Widget buildObjectState(BuildContext context, ViewData view, ObjectCubitState state) {
//     if (state is ObjectCubitUpdating || state is ObjectCubitIdle) {
//       return view.loadingBuilder(context, 0.0);
//     } else if (state is ObjectCubitUpdateFailed) {
//       return view.errorBuilder(context, state.failure);
//     } else if (state is ObjectCubitUpdated && !state.hasValue) {
//       return view.emptyBuilder(context);
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final valueCubit = widget.dynamicCubit;
//     assert(valueCubit != null);
//
//     final view = ViewDataProvider.of(context);
//     //     .copyWith(
//     //   errorBuilder: widget.errorBuilder,
//     //   loadingBuilder: widget.loadingBuilder,
//     //   emptyBuilder: widget.emptyBuilder,
//     // );
//
//     return BlocConsumer<DynamicCubit<S>, S>(
//       cubit: valueCubit,
//       listener: (context, state) {},
//       builder: (context, state) {
//         Widget current;
//
//         /// build a error widget if the state have a error
//         if (state is ObjectCubitState) {
//           current = buildObjectState(context, view, state);
//         } else if (state is IterableCubitState) {
//           /// build a loading widget if the state is not initilized
//           current = buildIterableState(context, view, state);
//         }
//         // else if (widget.plugin != null) {
//         //   current = widget.plugin.apply(valueCubit, state, widget.builder(context, state));
//         // }
//
//         return current ?? widget.builder(context, state);
//       },
//     );
//   }
// }
