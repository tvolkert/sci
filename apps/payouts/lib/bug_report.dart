import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:payouts/src/pivot.dart' as pivot;

void main() {
  runApp(BugReport());
}

class BugReport extends StatelessWidget {
  pivot.TableCellRenderer _basicRenderer(String columnName) {
    return ({
      BuildContext context,
      int rowIndex,
      int columnIndex,
    }) {
      return Padding(
        padding: EdgeInsets.all(2),
        child: Text('${columnName}_${rowIndex}'),
      );
    };
  }

  Widget _renderBar({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    String columnName,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ColoredBox(
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Text('bar_$rowIndex'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: pivot.ScrollPane(
          horizontalScrollBarPolicy: pivot.ScrollBarPolicy.stretch,
          view: pivot.BasicTableView(
            rowHeight: 22,
            length: 1000000,
            columns: [
              pivot.BasicTableColumn(
                width: pivot.FixedTableColumnWidth(150),
                cellRenderer: _basicRenderer('foo'),
              ),
              pivot.BasicTableColumn(
                width: pivot.FlexTableColumnWidth(),
                cellRenderer: _renderBar,
              ),
              pivot.BasicTableColumn(
                width: pivot.FixedTableColumnWidth(275),
                cellRenderer: _basicRenderer('baz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
