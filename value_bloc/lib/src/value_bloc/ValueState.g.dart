// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ValueState.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ValueBlocState<V, Filter> extends ValueBlocState<V, Filter> {
  @override
  final LoadStatusValueBloc loadStatus;
  @override
  final FetchStatusValueBloc fetchStatus;
  @override
  final V value;
  @override
  final bool refreshStatus;
  @override
  final Filter filter;

  factory _$ValueBlocState(
          [void Function(ValueBlocStateBuilder<V, Filter>) updates]) =>
      (new ValueBlocStateBuilder<V, Filter>()..update(updates)).build();

  _$ValueBlocState._(
      {this.loadStatus,
      this.fetchStatus,
      this.value,
      this.refreshStatus,
      this.filter})
      : super._() {
    if (loadStatus == null) {
      throw new BuiltValueNullFieldError('ValueBlocState', 'loadStatus');
    }
    if (fetchStatus == null) {
      throw new BuiltValueNullFieldError('ValueBlocState', 'fetchStatus');
    }
    if (refreshStatus == null) {
      throw new BuiltValueNullFieldError('ValueBlocState', 'refreshStatus');
    }
    if (V == dynamic) {
      throw new BuiltValueMissingGenericsError('ValueBlocState', 'V');
    }
    if (Filter == dynamic) {
      throw new BuiltValueMissingGenericsError('ValueBlocState', 'Filter');
    }
  }

  @override
  ValueBlocState<V, Filter> rebuild(
          void Function(ValueBlocStateBuilder<V, Filter>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ValueBlocStateBuilder<V, Filter> toBuilder() =>
      new ValueBlocStateBuilder<V, Filter>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ValueBlocState &&
        loadStatus == other.loadStatus &&
        fetchStatus == other.fetchStatus &&
        value == other.value &&
        refreshStatus == other.refreshStatus &&
        filter == other.filter;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, loadStatus.hashCode), fetchStatus.hashCode),
                value.hashCode),
            refreshStatus.hashCode),
        filter.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ValueBlocState')
          ..add('loadStatus', loadStatus)
          ..add('fetchStatus', fetchStatus)
          ..add('value', value)
          ..add('refreshStatus', refreshStatus)
          ..add('filter', filter))
        .toString();
  }
}

class ValueBlocStateBuilder<V, Filter>
    implements
        Builder<ValueBlocState<V, Filter>, ValueBlocStateBuilder<V, Filter>>,
        BaseBlocStateBuilder<Filter> {
  _$ValueBlocState<V, Filter> _$v;

  LoadStatusValueBloc _loadStatus;
  LoadStatusValueBloc get loadStatus => _$this._loadStatus;
  set loadStatus(LoadStatusValueBloc loadStatus) =>
      _$this._loadStatus = loadStatus;

  FetchStatusValueBloc _fetchStatus;
  FetchStatusValueBloc get fetchStatus => _$this._fetchStatus;
  set fetchStatus(FetchStatusValueBloc fetchStatus) =>
      _$this._fetchStatus = fetchStatus;

  V _value;
  V get value => _$this._value;
  set value(V value) => _$this._value = value;

  bool _refreshStatus;
  bool get refreshStatus => _$this._refreshStatus;
  set refreshStatus(bool refreshStatus) =>
      _$this._refreshStatus = refreshStatus;

  Filter _filter;
  Filter get filter => _$this._filter;
  set filter(Filter filter) => _$this._filter = filter;

  ValueBlocStateBuilder();

  ValueBlocStateBuilder<V, Filter> get _$this {
    if (_$v != null) {
      _loadStatus = _$v.loadStatus;
      _fetchStatus = _$v.fetchStatus;
      _value = _$v.value;
      _refreshStatus = _$v.refreshStatus;
      _filter = _$v.filter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ValueBlocState<V, Filter> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ValueBlocState<V, Filter>;
  }

  @override
  void update(void Function(ValueBlocStateBuilder<V, Filter>) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ValueBlocState<V, Filter> build() {
    ValueBlocState._finalizeBuilder(this);
    final _$result = _$v ??
        new _$ValueBlocState<V, Filter>._(
            loadStatus: loadStatus,
            fetchStatus: fetchStatus,
            value: value,
            refreshStatus: refreshStatus,
            filter: filter);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
