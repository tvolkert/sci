import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/pivot/basic_table_view.dart';

void main() {
  runApp(BugReport());
}

class BugReport extends StatelessWidget {
  Widget _renderBar({
    BuildContext context,
    Map<dynamic, dynamic> row,
    int rowIndex,
    int columnIndex,
    BasicTableView<Map<dynamic, dynamic>> tableView,
    String columnName,
    bool selected,
    bool highlighted,
    bool enabled,
  }) {
    dynamic value = row['bar'];
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
            child: Text('$value'),
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
//        view: SizedBox(width: 100, height: 1100),
            view: BasicTableView<Map<dynamic, dynamic>>(
              rowHeight: 22,
              columns: [
                BasicTableColumn(
                  name: 'foo',
                  width: FixedTableColumnWidth(150),
                ),
                BasicTableColumn(
                  name: 'bar',
                  width: FlexTableColumnWidth(),
                  cellRenderer: _renderBar,
                ),
                BasicTableColumn(
                  name: 'baz',
                  width: FixedTableColumnWidth(275),
                ),
              ],
              data: List<Map<dynamic, dynamic>>.generate(100000, (int index) {
                return <dynamic, dynamic>{
                  'foo': 'foo_$index',
                  'bar': 'bar_$index',
                  'baz': 'baz_$index',
                };
              }),
            ),
        ),
      ),
    );
  }
}
