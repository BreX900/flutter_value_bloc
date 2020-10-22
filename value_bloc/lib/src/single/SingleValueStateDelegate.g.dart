// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SingleValueStateDelegate.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SingleValueStateDelegate<V, Filter>
    extends SingleValueStateDelegate<V, Filter> {
  @override
  final V value;
  @override
  final Filter filter;
  @override
  final bool clearAfterFetch;

  factory _$SingleValueStateDelegate(
          [void Function(SingleValueStateDelegateBuilder<V, Filter>)
              updates]) =>
      (new SingleValueStateDelegateBuilder<V, Filter>()..update(updates))
          .build();

  _$SingleValueStateDelegate._({this.value, this.filter, this.clearAfterFetch})
      : super._() {
    if (clearAfterFetch == null) {
      throw new BuiltValueNullFieldError(
          'SingleValueStateDelegate', 'clearAfterFetch');
    }
    if (V == dynamic) {
      throw new BuiltValueMissingGenericsError('SingleValueStateDelegate', 'V');
    }
    if (Filter == dynamic) {
      throw new BuiltValueMissingGenericsError(
          'SingleValueStateDelegate', 'Filter');
    }
  }

  @override
  SingleValueStateDelegate<V, Filter> rebuild(
          void Function(SingleValueStateDelegateBuilder<V, Filter>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SingleValueStateDelegateBuilder<V, Filter> toBuilder() =>
      new SingleValueStateDelegateBuilder<V, Filter>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SingleValueStateDelegate &&
        value == other.value &&
        filter == other.filter &&
        clearAfterFetch == other.clearAfterFetch;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, value.hashCode), filter.hashCode),
        clearAfterFetch.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SingleValueStateDelegate')
          ..add('value', value)
          ..add('filter', filter)
          ..add('clearAfterFetch', clearAfterFetch))
        .toString();
  }
}

class SingleValueStateDelegateBuilder<V, Filter>
    implements
        Builder<SingleValueStateDelegate<V, Filter>,
            SingleValueStateDelegateBuilder<V, Filter>>,
        ValueStateDelegateBuilder<Filter> {
  _$SingleValueStateDelegate<V, Filter> _$v;

  V _value;
  V get value => _$this._value;
  set value(V value) => _$this._value = value;

  Filter _filter;
  Filter get filter => _$this._filter;
  set filter(Filter filter) => _$this._filter = filter;

  bool _clearAfterFetch;
  bool get clearAfterFetch => _$this._clearAfterFetch;
  set clearAfterFetch(bool clearAfterFetch) =>
      _$this._clearAfterFetch = clearAfterFetch;

  SingleValueStateDelegateBuilder();

  SingleValueStateDelegateBuilder<V, Filter> get _$this {
    if (_$v != null) {
      _value = _$v.value;
      _filter = _$v.filter;
      _clearAfterFetch = _$v.clearAfterFetch;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant SingleValueStateDelegate<V, Filter> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$SingleValueStateDelegate<V, Filter>;
  }

  @override
  void update(
      void Function(SingleValueStateDelegateBuilder<V, Filter>) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SingleValueStateDelegate<V, Filter> build() {
    SingleValueStateDelegate._finalizeBuilder(this);
    final _$result = _$v ??
        new _$SingleValueStateDelegate<V, Filter>._(
            value: value, filter: filter, clearAfterFetch: clearAfterFetch);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
