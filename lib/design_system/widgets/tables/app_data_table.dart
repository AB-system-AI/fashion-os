import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

typedef DataTableRowBuilder<T> = List<DataCell> Function(T item);

/// Responsive data table with sorting, selection, and pagination controls.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    required this.columns,
    required this.rows,
    required this.rowBuilder,
    required this.itemKey,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.selectedKeys = const {},
    this.onSelectionChanged,
    this.page,
    this.pageSize,
    this.totalCount,
    this.onPageChanged,
    super.key,
  });

  final List<DataColumn> columns;
  final List<T> rows;
  final DataTableRowBuilder<T> rowBuilder;
  final String Function(T item) itemKey;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;
  final Set<String> selectedKeys;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final int? page;
  final int? pageSize;
  final int? totalCount;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final table = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              columns: columns,
              rows: rows.map((item) {
                final key = itemKey(item);
                final cells = rowBuilder(item);
                if (onSelectionChanged == null) {
                  return DataRow(cells: cells);
                }
                return DataRow(
                  selected: selectedKeys.contains(key),
                  onSelectChanged: (selected) {
                    final next = Set<String>.from(selectedKeys);
                    if (selected == true) {
                      next.add(key);
                    } else {
                      next.remove(key);
                    }
                    onSelectionChanged!(next);
                  },
                  cells: cells,
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (page == null || pageSize == null || totalCount == null) {
      return table;
    }

    final totalPages = (totalCount! / pageSize!).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: table),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Page $page of $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page! > 1 ? () => onPageChanged?.call(page! - 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page! < totalPages ? () => onPageChanged?.call(page! + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
