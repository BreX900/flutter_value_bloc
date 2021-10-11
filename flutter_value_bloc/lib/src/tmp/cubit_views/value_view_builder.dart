// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_value_bloc/src/cubit_views/cubit_views.dart';
// import 'package:flutter_value_bloc/src/cubit_views/cubit_views_provider.dart';
// import 'package:value_bloc/value_bloc.dart';
//
// abstract class CubitViewBuilder<C extends Cubit<S>, S extends Object> extends StatelessWidget {
//   final C? cubit;
//   final LoadingCubitViewBuilder<C, S> loadingBuilder;
//   final ErrorCubitViewBuilder<C, S> errorBuilder;
//   final EmptyCubitViewBuilder<C, S> emptyBuilder;
//   final BlocWidgetBuilder<S> builder;
//
//   const CubitViewBuilder._({
//     Key? key,
//     this.cubit,
//     this.loadingBuilder = CubitViewBuilder.buildLoading,
//     this.errorBuilder = CubitViewBuilder.buildError,
//     this.emptyBuilder = CubitViewBuilder.buildEmpty,
//     required this.builder,
//   }) : super(key: key);
//
//   static Widget buildError(BuildContext context, Cubit<Object> cubit, Object state) {
//     return CubitViewsProvider.of(context).errorBuilder(context, cubit, state);
//   }
//
//   static Widget buildLoading(BuildContext context, Cubit<Object> cubit, Object state) {
//     return CubitViewsProvider.of(context).loadingBuilder(context, cubit, state);
//   }
//
//   static Widget buildEmpty(BuildContext context, Cubit<Object> cubit, Object state) {
//     return CubitViewsProvider.of(context).emptyBuilder(context, cubit, state);
//   }
//
//   // static var viewBuilder = (BuildContext context, Object state) {
//   //   if (state is ObjectCubitUpdating || state is IterableCubitUpdating) {}
//   // };
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<C, S>(
//       bloc: cubit,
//       builder: (context, state) {
//         return builder(context, state);
//       },
//     );
//   }
// }
