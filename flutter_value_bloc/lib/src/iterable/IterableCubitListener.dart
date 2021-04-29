import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class IterableCubitListener<Value, ExtraData> extends StatelessWidget {
  final IterableCubit<Value, ExtraData> iterableCubit;
  final BlocListenerCondition<IterableCubitState<Value, ExtraData>> listenWhen;
  final BlocWidgetListener<IterableCubitUpdating<Value, ExtraData>>? onUpdating;
  final BlocWidgetListener<IterableCubitUpdateFailed<Value, ExtraData>>? onUpdateFailed;
  final BlocWidgetListener<IterableCubitUpdated<Value, ExtraData>>? onUpdated;
  final Widget child;

  const IterableCubitListener({
    Key? key,
    required this.iterableCubit,
    this.listenWhen = _listenWhen,
    this.onUpdating,
    this.onUpdateFailed,
    this.onUpdated,
    required this.child,
  }) : super(key: key);

  static bool _listenWhen(
    IterableCubitState<dynamic, dynamic> p,
    IterableCubitState<dynamic, dynamic> c,
  ) {
    return p.runtimeType != c.runtimeType;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IterableCubit<Value, ExtraData>, IterableCubitState<Value, ExtraData>>(
      bloc: iterableCubit,
      listenWhen: listenWhen,
      listener: (context, state) {
        if (state is IterableCubitUpdating<Value, ExtraData>) {
          if (onUpdating != null) {
            onUpdating!(context, state);
          }
        } else if (state is IterableCubitUpdateFailed<Value, ExtraData>) {
          if (onUpdateFailed != null) {
            onUpdateFailed!(context, state);
          }
        } else if (state is IterableCubitUpdated<Value, ExtraData>) {
          if (onUpdated != null) {
            onUpdated!(context, state);
          }
        }
      },
      child: child,
    );
  }
}
