import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:chicago/chicago.dart' as chicago;

void main() {
  runApp(BugReport());
}

class BugReport extends StatelessWidget {
  chicago.BasicTableCellRenderer _basicRenderer(String columnName) {
    return ({
      required BuildContext context,
      required int rowIndex,
      required int columnIndex,
    }) {
      return Padding(
        padding: EdgeInsets.all(2),
        child: Text('${columnName}_$rowIndex'),
      );
    };
  }

  Widget _renderBar({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
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
        child: chicago.ScrollPane(
          horizontalScrollBarPolicy: chicago.ScrollBarPolicy.stretch,
          view: chicago.BasicTableView(
            rowHeight: 22,
            length: 1000000,
            columns: [
              chicago.BasicTableColumn(
                width: chicago.FixedTableColumnWidth(150),
                cellRenderer: _basicRenderer('foo'),
              ),
              chicago.BasicTableColumn(
                width: chicago.FlexTableColumnWidth(),
                cellRenderer: _renderBar,
              ),
              chicago.BasicTableColumn(
                width: chicago.FixedTableColumnWidth(275),
                cellRenderer: _basicRenderer('baz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
