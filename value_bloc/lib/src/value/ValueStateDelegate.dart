import 'package:built_value/built_value.dart';

part 'ValueStateDelegate.g.dart';

/// Full = isEmpty: false, isFully: true
/// Empty = isEmpty: true, isFully: false
/// Loading = isEmpty: null, isFully: null
/// HasData = isEmpty: false, isFully: false
@BuiltValue(instantiable: false)
abstract class ValueStateDelegate<Filter> {
  @nullable
  Filter get filter;

  static void finalizeBuilder(ValueStateDelegateBuilder b) {}

  ValueStateDelegate<Filter> rebuild(
      covariant Function(ValueStateDelegateBuilder<Filter> b) updates);

  ValueStateDelegateBuilder<Filter> toBuilder();
}
