import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/src/cubit_views/CubitViews.dart';
import 'package:value_bloc/value_bloc.dart';

abstract class IterableCubitBuilderBase<Value> extends StatelessWidget {
  final IterableCubit<Value, Object> iterableCubit;

  /// Number of values to skip show
  final int skipValuesCount;

  /// Number of values to show
  final int takeValuesCount;

  final bool useOldValues;

  /// [CubitViewBuilder.loadingBuilder]
  final LoadingCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
      loadingBuilder;

  /// [CubitViewBuilder.errorBuilder]
  final ErrorCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
      errorBuilder;

  /// [CubitViewBuilder.emptyBuilder]
  final EmptyCubitViewBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>
      emptyBuilder;

  const IterableCubitBuilderBase({
    Key key,
    @required this.iterableCubit,
    this.skipValuesCount = 0,
    this.takeValuesCount,
    this.useOldValues = false,
    this.loadingBuilder = CubitViewBuilder.buildLoading,
    this.errorBuilder = CubitViewBuilder.buildError,
    this.emptyBuilder = CubitViewBuilder.buildEmpty,
  })  : assert(iterableCubit != null),
        assert(skipValuesCount != null && skipValuesCount >= 0, '${skipValuesCount}'),
        assert(takeValuesCount == null || takeValuesCount > 0, '${takeValuesCount}'),
        super(key: key);

  Widget buildDecoration(BuildContext context, Widget child) => child;

  Widget buildValues(
    BuildContext context,
    IterableCubitState<Value, Object> state,
    BuiltList<Value> values,
  );

  @override
  Widget build(BuildContext context) {
    final current = BlocBuilder<IterableCubit<Value, Object>, IterableCubitState<Value, Object>>(
      cubit: iterableCubit,
      builder: (context, state) {
        if (state is IterableCubitUpdating<Value, Object>) {
          if ((!useOldValues || state.oldAllValues.isEmpty) && loadingBuilder != null) {
            return loadingBuilder(context, iterableCubit, state);
          }
        } else if (state is IterableCubitUpdateFailed<Value, Object>) {
          if (errorBuilder != null) {
            return errorBuilder(context, iterableCubit, state);
          }
        } else {
          final length = skipValuesCount - state.values.length;
          if (length <= 0) {
            if (emptyBuilder != null) {
              return emptyBuilder(context, iterableCubit, state);
            }
          }
        }

        var values = useOldValues && state is IterableCubitUpdating<Value, Object>
            ? state.oldValues
            : state.values;

        values = values.rebuild((b) {
          if (skipValuesCount > 0) b.skip(skipValuesCount);
          if (takeValuesCount != null) b.take(takeValuesCount);
        });

        return buildValues(context, state, values);
      },
    );
    return buildDecoration(context, current);
  }
}
