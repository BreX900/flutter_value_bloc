class Tuple2<Value1, Value2> {
  final Value1 value1;
  final Value2 value2;

  Tuple2(this.value1, this.value2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          value1 == other.value1 &&
          value2 == other.value2;

  @override
  int get hashCode => value1.hashCode ^ value2.hashCode;
}
