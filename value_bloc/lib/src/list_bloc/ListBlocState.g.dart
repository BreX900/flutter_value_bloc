// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ListBlocState.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListBlocState<V, Filter> extends ListBlocState<V, Filter> {
  @override
  final LoadStatusValueBloc loadStatus;
  @override
  final FetchStatusValueBloc fetchStatus;
  @override
  final int countValues;
  @override
  final BuiltList<V> values;
  @override
  final bool refreshStatus;
  @override
  final Filter filter;

  factory _$ListBlocState(
          [void Function(ListBlocStateBuilder<V, Filter>) updates]) =>
      (new ListBlocStateBuilder<V, Filter>()..update(updates)).build();

  _$ListBlocState._(
      {this.loadStatus,
      this.fetchStatus,
      this.countValues,
      this.values,
      this.refreshStatus,
      this.filter})
      : super._() {
    if (loadStatus == null) {
      throw new BuiltValueNullFieldError('ListBlocState', 'loadStatus');
    }
    if (fetchStatus == null) {
      throw new BuiltValueNullFieldError('ListBlocState', 'fetchStatus');
    }
    if (values == null) {
      throw new BuiltValueNullFieldError('ListBlocState', 'values');
    }
    if (refreshStatus == null) {
      throw new BuiltValueNullFieldError('ListBlocState', 'refreshStatus');
    }
    if (V == dynamic) {
      throw new BuiltValueMissingGenericsError('ListBlocState', 'V');
    }
    if (Filter == dynamic) {
      throw new BuiltValueMissingGenericsError('ListBlocState', 'Filter');
    }
  }

  @override
  ListBlocState<V, Filter> rebuild(
          void Function(ListBlocStateBuilder<V, Filter>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListBlocStateBuilder<V, Filter> toBuilder() =>
      new ListBlocStateBuilder<V, Filter>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListBlocState &&
        loadStatus == other.loadStatus &&
        fetchStatus == other.fetchStatus &&
        countValues == other.countValues &&
        values == other.values &&
        refreshStatus == other.refreshStatus &&
        filter == other.filter;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, loadStatus.hashCode), fetchStatus.hashCode),
                    countValues.hashCode),
                values.hashCode),
            refreshStatus.hashCode),
        filter.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ListBlocState')
          ..add('loadStatus', loadStatus)
          ..add('fetchStatus', fetchStatus)
          ..add('countValues', countValues)
          ..add('values', values)
          ..add('refreshStatus', refreshStatus)
          ..add('filter', filter))
        .toString();
  }
}

class ListBlocStateBuilder<V, Filter>
    implements
        Builder<ListBlocState<V, Filter>, ListBlocStateBuilder<V, Filter>>,
        BaseBlocStateBuilder<Filter> {
  _$ListBlocState<V, Filter> _$v;

  LoadStatusValueBloc _loadStatus;
  LoadStatusValueBloc get loadStatus => _$this._loadStatus;
  set loadStatus(LoadStatusValueBloc loadStatus) =>
      _$this._loadStatus = loadStatus;

  FetchStatusValueBloc _fetchStatus;
  FetchStatusValueBloc get fetchStatus => _$this._fetchStatus;
  set fetchStatus(FetchStatusValueBloc fetchStatus) =>
      _$this._fetchStatus = fetchStatus;

  int _countValues;
  int get countValues => _$this._countValues;
  set countValues(int countValues) => _$this._countValues = countValues;

  ListBuilder<V> _values;
  ListBuilder<V> get values => _$this._values ??= new ListBuilder<V>();
  set values(ListBuilder<V> values) => _$this._values = values;

  bool _refreshStatus;
  bool get refreshStatus => _$this._refreshStatus;
  set refreshStatus(bool refreshStatus) =>
      _$this._refreshStatus = refreshStatus;

  Filter _filter;
  Filter get filter => _$this._filter;
  set filter(Filter filter) => _$this._filter = filter;

  ListBlocStateBuilder();

  ListBlocStateBuilder<V, Filter> get _$this {
    if (_$v != null) {
      _loadStatus = _$v.loadStatus;
      _fetchStatus = _$v.fetchStatus;
      _countValues = _$v.countValues;
      _values = _$v.values?.toBuilder();
      _refreshStatus = _$v.refreshStatus;
      _filter = _$v.filter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ListBlocState<V, Filter> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ListBlocState<V, Filter>;
  }

  @override
  void update(void Function(ListBlocStateBuilder<V, Filter>) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ListBlocState<V, Filter> build() {
    ListBlocState._finalizeBuilder(this);
    _$ListBlocState<V, Filter> _$result;
    try {
      _$result = _$v ??
          new _$ListBlocState<V, Filter>._(
              loadStatus: loadStatus,
              fetchStatus: fetchStatus,
              countValues: countValues,
              values: values.build(),
              refreshStatus: refreshStatus,
              filter: filter);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'values';
        values.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ListBlocState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
