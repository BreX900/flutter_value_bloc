library value_bloc;

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';

import 'src/base/BaseBlocState.dart';
import 'src/list_bloc/ListBlocState.dart';
import 'src/status.dart';
import 'src/value_bloc/ValueState.dart';

export 'package:bloc/bloc.dart';

export 'src/list_bloc/ListBlocState.dart';
export 'src/status.dart';
export 'src/value_bloc/ValueState.dart';

part 'src/base/BaseBloc.dart';
part 'src/list_bloc/ListBloc.dart';
part 'src/value_bloc/ValueBloc.dart';

extension ListBuilderExt<T> on ListBuilder<T> {
  /// this: [1, 2, 3, 4, 5], start: 3, values = [6, 7, 8, 9]
  /// [1, 2, 3, 6, 7, 8, 9]
  void push(int start, Iterable<T> values) {
    final newLength = start + values.length;
    final newValuesCount = newLength - length;
    if (newValuesCount > 0) {
      addAll(values.skip(values.length - newValuesCount));
    }
    final oldValuesCount = length - start;
    if (oldValuesCount > 0) {
      setRange(start, start + oldValuesCount, values);
    }
  }

  void pushRange(int start, int end, Iterable<T> values) {
    values = values.take(end - start);
    final newLength = start + values.length;
    final newValuesCount = newLength - length;
    if (newValuesCount > 0) {
      addAll(values.skip(values.length - newValuesCount));
    }
    final oldValuesCount = length - start;
    if (oldValuesCount > 0) {
      setRange(start, start + oldValuesCount, values);
    }
  }
}
