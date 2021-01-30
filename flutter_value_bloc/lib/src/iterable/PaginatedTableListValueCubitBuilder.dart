import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

typedef _RowBuilder<V> = DataRow Function(V value);

/// Build a [PaginatedDataTable] with [ListValueCubit]
class PaginatedDataTableCubitBuilder<V> extends StatefulWidget {
  final IterableCubit<V, Object> iterableCubit;
  final int rowsPerPage;
  final Widget header;
  final List<DataColumn> columns;
  final _RowBuilder<V> builder;

  const PaginatedDataTableCubitBuilder({
    Key key,
    @required this.iterableCubit,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    @required this.header,
    @required this.columns,
    @required this.builder,
  }) : super(key: key);

  @override
  _PaginatedDataTableCubitBuilderState<V> createState() => _PaginatedDataTableCubitBuilderState();
}

class _PaginatedDataTableCubitBuilderState<V> extends State<PaginatedDataTableCubitBuilder<V>> {
  _DataTableSource<V> _source;

  @override
  void initState() {
    super.initState();
    _source = _DataTableSource<V>(
      data: getData(widget.iterableCubit.state),
      builder: widget.builder,
    );
    final iterableCubit = widget.iterableCubit;
    if (iterableCubit is MultiCubit<V, Object>) {
      iterableCubit.fetch(section: IterableSection(0, widget.rowsPerPage));
    }
  }

  @override
  void didUpdateWidget(covariant PaginatedDataTableCubitBuilder<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.builder != oldWidget.builder) {
      _source.builder = widget.builder;
    }
  }

  _Data<V> getData(IterableCubitState<V, Object> state) {
    return _Data<V>(
      values: state.allValues,
      isRowCountApproximate: state.length == null,
      rowCount: state.length ?? state.allValues.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iterableCubit = widget.iterableCubit;

    return BlocListener<IterableCubit<V, Object>, IterableCubitState<V, Object>>(
      cubit: iterableCubit,
      listener: (context, state) => _source.data = getData(state),
      child: PaginatedDataTable(
        onPageChanged: (offset) {
          if (iterableCubit is MultiCubit<V, Object>) {
            iterableCubit.fetch(section: IterableSection(offset, widget.rowsPerPage));
          }
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

  _DataTableSource({
    @required _Data data,
    @required _RowBuilder<V> builder,
  })  : _data = data,
        _builder = builder;

  set data(_Data data) {
    if (_data == data) return;
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
  final BuiltMap<int, V> values;
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
          values == other.values &&
          isRowCountApproximate == other.isRowCountApproximate &&
          rowCount == other.rowCount;

  @override
  int get hashCode => values.hashCode ^ isRowCountApproximate.hashCode ^ rowCount.hashCode;

  @override
  String toString() {
    return '_Data{values: $values, isRowCountApproximate: $isRowCountApproximate, rowCount: $rowCount}';
  }
}
