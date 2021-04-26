import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(BugReport());
}

class BugReport extends StatelessWidget {
  chicago.BasicTableCellBuilder _basicRenderer(String columnName) {
    return (BuildContext context, int rowIndex, int columnIndex) {
      return Padding(
        padding: EdgeInsets.all(2),
        child: Text('${columnName}_$rowIndex'),
      );
    };
  }

  Widget _renderBar(BuildContext context, int rowIndex, int columnIndex) {
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
                cellBuilder: _basicRenderer('foo'),
              ),
              chicago.BasicTableColumn(
                width: chicago.FlexTableColumnWidth(),
                cellBuilder: _renderBar,
              ),
              chicago.BasicTableColumn(
                width: chicago.FixedTableColumnWidth(275),
                cellBuilder: _basicRenderer('baz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
