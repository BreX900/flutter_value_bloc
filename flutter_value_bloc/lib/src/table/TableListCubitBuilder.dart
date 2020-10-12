import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

typedef _RowBuilder<V> = DataRow Function(V value);

class PaginatedTableListCubitBuilder<C extends ListValueCubit<V, Filter>, V,
    Filter> extends StatefulWidget {
  final C listCubit;
  final int rowsPerPage;
  final Widget header;
  final List<DataColumn> columns;
  final _RowBuilder<V> builder;

  const PaginatedTableListCubitBuilder({
    Key key,
    this.listCubit,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    @required this.header,
    @required this.columns,
    @required this.builder,
  }) : super(key: key);

  @override
  _PaginatedTableListCubitBuilderState<C, V, Filter> createState() =>
      _PaginatedTableListCubitBuilderState();
}

class _PaginatedTableListCubitBuilderState<C extends ListValueCubit<V, Filter>,
    V, Filter> extends State<PaginatedTableListCubitBuilder<C, V, Filter>> {
  _DataTableSource<V> _source;

  @override
  void initState() {
    super.initState();
    _source = _DataTableSource<V>(
      data: getData((context.bloc<C>() ?? widget.listCubit).state),
    );
  }

  @override
  void didUpdateWidget(
      covariant PaginatedTableListCubitBuilder<C, V, Filter> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.builder != oldWidget.builder) {
      _source.builder = widget.builder;
    }
  }

  _Data<V> getData(ListValueState state) {
    return _Data<V>(
      values: state.values,
      isRowCountApproximate: state.countValues == null,
      rowCount: state.countValues ?? state.values.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listCubit = widget.listCubit ?? context.bloc<C>();
    return BlocListener<C, ListValueState<V, Filter>>(
      cubit: listCubit,
      listener: (context, state) => _source.data = getData(state),
      child: PaginatedDataTable(
        onPageChanged: (offset) {
          listCubit.fetch(offset: offset, limit: widget.rowsPerPage);
        },
        source: _source,
        header: widget.header,
        columns: widget.columns,
      ),
    );
  }
}

class _DataTableSource<V> extends DataTableSource {
  _Data<V> _data;
  _RowBuilder<V> _builder;

  _DataTableSource({@required _Data data}) : _data = data;

  set data(_Data data) {
    if (_data == _data) return;
    _data = data;
    notifyListeners();
  }

  set builder(_RowBuilder<V> builder) {
    if (_builder == builder) return;
    _builder = builder;
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => _data.isRowCountApproximate;

  @override
  int get rowCount => _data.rowCount;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return _builder(_data.values[index]);
  }
}

class _Data<V> {
  final BuiltList<V> values;
  final bool isRowCountApproximate;
  final int rowCount;

  const _Data({
    @required this.values,
    @required this.isRowCountApproximate,
    @required this.rowCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Data &&
          runtimeType == other.runtimeType &&
          isRowCountApproximate == other.isRowCountApproximate &&
          rowCount == other.rowCount;

  @override
  int get hashCode => isRowCountApproximate.hashCode ^ rowCount.hashCode;
}
