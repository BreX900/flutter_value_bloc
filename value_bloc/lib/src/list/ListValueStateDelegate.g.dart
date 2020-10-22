// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ListValueStateDelegate.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListValueStateDelegate<V, Filter>
    extends ListValueStateDelegate<V, Filter> {
  @override
  final int countValues;
  @override
  final BuiltMap<FetchScheme, BuiltList<V>> pages;
  @override
  final Filter filter;
  @override
  final bool clearAfterFetch;
  BuiltList<V> __values;

  factory _$ListValueStateDelegate(
          [void Function(ListValueStateDelegateBuilder<V, Filter>) updates]) =>
      (new ListValueStateDelegateBuilder<V, Filter>()..update(updates)).build();

  _$ListValueStateDelegate._(
      {this.countValues, this.pages, this.filter, this.clearAfterFetch})
      : super._() {
    if (pages == null) {
      throw new BuiltValueNullFieldError('ListValueStateDelegate', 'pages');
    }
    if (clearAfterFetch == null) {
      throw new BuiltValueNullFieldError(
          'ListValueStateDelegate', 'clearAfterFetch');
    }
    if (V == dynamic) {
      throw new BuiltValueMissingGenericsError('ListValueStateDelegate', 'V');
    }
    if (Filter == dynamic) {
      throw new BuiltValueMissingGenericsError(
          'ListValueStateDelegate', 'Filter');
    }
  }

  @override
  BuiltList<V> get values => __values ??= super.values;

  @override
  ListValueStateDelegate<V, Filter> rebuild(
          void Function(ListValueStateDelegateBuilder<V, Filter>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListValueStateDelegateBuilder<V, Filter> toBuilder() =>
      new ListValueStateDelegateBuilder<V, Filter>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListValueStateDelegate &&
        countValues == other.countValues &&
        pages == other.pages &&
        filter == other.filter &&
        clearAfterFetch == other.clearAfterFetch;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, countValues.hashCode), pages.hashCode), filter.hashCode),
        clearAfterFetch.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ListValueStateDelegate')
          ..add('countValues', countValues)
          ..add('pages', pages)
          ..add('filter', filter)
          ..add('clearAfterFetch', clearAfterFetch))
        .toString();
  }
}

class ListValueStateDelegateBuilder<V, Filter>
    implements
        Builder<ListValueStateDelegate<V, Filter>,
            ListValueStateDelegateBuilder<V, Filter>>,
        ValueStateDelegateBuilder<Filter> {
  _$ListValueStateDelegate<V, Filter> _$v;

  int _countValues;
  int get countValues => _$this._countValues;
  set countValues(int countValues) => _$this._countValues = countValues;

  MapBuilder<FetchScheme, BuiltList<V>> _pages;
  MapBuilder<FetchScheme, BuiltList<V>> get pages =>
      _$this._pages ??= new MapBuilder<FetchScheme, BuiltList<V>>();
  set pages(MapBuilder<FetchScheme, BuiltList<V>> pages) =>
      _$this._pages = pages;

  Filter _filter;
  Filter get filter => _$this._filter;
  set filter(Filter filter) => _$this._filter = filter;

  bool _clearAfterFetch;
  bool get clearAfterFetch => _$this._clearAfterFetch;
  set clearAfterFetch(bool clearAfterFetch) =>
      _$this._clearAfterFetch = clearAfterFetch;

  ListValueStateDelegateBuilder();

  ListValueStateDelegateBuilder<V, Filter> get _$this {
    if (_$v != null) {
      _countValues = _$v.countValues;
      _pages = _$v.pages?.toBuilder();
      _filter = _$v.filter;
      _clearAfterFetch = _$v.clearAfterFetch;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ListValueStateDelegate<V, Filter> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ListValueStateDelegate<V, Filter>;
  }

  @override
  void update(void Function(ListValueStateDelegateBuilder<V, Filter>) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ListValueStateDelegate<V, Filter> build() {
    ListValueStateDelegate._finalizeBuilder(this);
    _$ListValueStateDelegate<V, Filter> _$result;
    try {
      _$result = _$v ??
          new _$ListValueStateDelegate<V, Filter>._(
              countValues: countValues,
              pages: pages.build(),
              filter: filter,
              clearAfterFetch: clearAfterFetch);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'pages';
        pages.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ListValueStateDelegate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
