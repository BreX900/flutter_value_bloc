import 'package:built_collection/built_collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

typedef _RowBuilder<V> = DataRow Function(V value);

/// Build a [PaginatedDataTable] with [ListValueCubit]
///
/// === PLEASE NOT CHANGE THE [rowsPerPage] AND [initialFirstRowIndex] ===
class PaginatedDataTableCubitBuilder<V> extends StatefulWidget {
  /// Used for creating ui based on data in this object
  final IterableCubit<V, Object> iterableCubit;

  /// See [PaginatedDataTable.rowsPerPage]
  final int rowsPerPage;

  /// See [PaginatedDataTable.availableRowsPerPage]
  final List<int> availableRowsPerPage;

  /// See [PaginatedDataTable.sortColumnIndex]
  final int sortColumnIndex;

  /// See [PaginatedDataTable.sortAscending]
  final bool sortAscending;

  /// See [PaginatedDataTable.dataRowHeight]
  final double dataRowHeight;

  /// See [PaginatedDataTable.headingRowHeight]
  final double headingRowHeight;

  /// See [PaginatedDataTable.horizontalMargin]
  final double horizontalMargin;

  /// See [PaginatedDataTable.columnSpacing]
  final double columnSpacing;

  /// See [PaginatedDataTable.initialFirstRowIndex]
  final int initialFirstRowIndex;

  /// See [PaginatedDataTable.dragStartBehavior]
  final DragStartBehavior dragStartBehavior;

  /// See [PaginatedDataTable.header]
  final Widget header;

  /// See [PaginatedDataTable.actions]
  final List<Widget> actions;

  /// See [PaginatedDataTable.columns]
  final List<DataColumn> columns;

  /// Build the row based on the value
  /// See [DataTableSource.getRow] for more details
  final _RowBuilder<V> builder;

  const PaginatedDataTableCubitBuilder({
    Key key,
    @required this.iterableCubit,
    this.initialFirstRowIndex = 0,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[
      PaginatedDataTable.defaultRowsPerPage,
      PaginatedDataTable.defaultRowsPerPage * 2,
      PaginatedDataTable.defaultRowsPerPage * 5,
      PaginatedDataTable.defaultRowsPerPage * 10,
    ],
    this.sortColumnIndex,
    this.sortAscending = true,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.dragStartBehavior = DragStartBehavior.start,
    @required this.header,
    this.actions = const <Widget>[],
    @required this.columns,
    @required this.builder,
  })  : assert(iterableCubit != null),
        assert(builder != null),
        super(key: key);

  @override
  _PaginatedDataTableCubitBuilderState<V> createState() => _PaginatedDataTableCubitBuilderState();
}

class _PaginatedDataTableCubitBuilderState<V> extends State<PaginatedDataTableCubitBuilder<V>> {
  _DataTableSource<V> _source;
  int _currentPageOffset;

  @override
  void initState() {
    super.initState();
    _currentPageOffset = (widget.initialFirstRowIndex / widget.rowsPerPage).floor();
    print('init: ${_currentPageOffset}');
    _source = _DataTableSource<V>(
      data: getData(widget.iterableCubit.state),
      builder: widget.builder,
    );
    final iterableCubit = widget.iterableCubit;
    if (iterableCubit is MultiCubit<V, Object>) {
      iterableCubit.fetch(section: IterableSection(_currentPageOffset, widget.rowsPerPage));
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
      listener: (context, state) {
        _source.data = getData(state);
        if (state is IterableCubitIdle<V, Object> && iterableCubit is MultiCubit<V, Object>) {
          // Todo: When page is empty after first work but if you navigate to previous page
          //       the values not fetching
          iterableCubit.fetch(section: IterableSection(_currentPageOffset, widget.rowsPerPage));
        }
      },
      child: PaginatedDataTable(
        initialFirstRowIndex: widget.initialFirstRowIndex,
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: widget.availableRowsPerPage,
        sortColumnIndex: widget.sortColumnIndex,
        header: widget.header,
        sortAscending: widget.sortAscending,
        dataRowHeight: widget.dataRowHeight,
        headingRowHeight: widget.headingRowHeight,
        horizontalMargin: widget.horizontalMargin,
        columnSpacing: widget.columnSpacing,
        dragStartBehavior: widget.dragStartBehavior,
        actions: widget.actions,
        onPageChanged: (offset) {
          _currentPageOffset = offset;
          if (iterableCubit is MultiCubit<V, Object>) {
            iterableCubit.fetch(section: IterableSection(offset, widget.rowsPerPage));
          }
        },
        source: _source,
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
