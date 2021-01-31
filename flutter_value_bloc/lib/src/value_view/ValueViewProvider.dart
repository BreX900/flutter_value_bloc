// import 'package:flutter/widgets.dart';
// import 'package:flutter_value_bloc/flutter_value_bloc.dart';
// import 'package:flutter_value_bloc/src/value_view/ValueViewData.dart';
// import 'package:provider/provider.dart';
//
// /// It provider in [SingleViewValueCubitBuilder] or
// /// [ListViewValueCubitBuilder] the defaults builders
// class ValueViewDataProvider extends Provider<ValueViewData> {
//   ValueViewDataProvider({
//     @required Create<ValueViewData> create,
//     TransitionBuilder builder,
//     Widget child,
//   }) : super(create: create, builder: builder, child: child);
//
//   ValueViewDataProvider.value({
//     @required ValueViewData value,
//     TransitionBuilder builder,
//     Widget child,
//   }) : super.value(value: value, builder: builder, child: child);
//
//   static ValueViewData of(BuildContext context) => context.watch<ValueViewData>();
//
//   static ValueViewData tryOf(BuildContext context) {
//     try {
//       return context.watch<ValueViewData>();
//     } on ProviderNotFoundException {
//       return ValueViewData.fromViewData(viewData: ViewDataProvider.tryOf(context));
//     }
//   }
// }
