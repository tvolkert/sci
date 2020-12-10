import 'package:flutter/widgets.dart' hide TableCell, TableRow;
import 'package:flutter_test/flutter_test.dart';
import 'package:payouts/src/pivot.dart';

void main() {
  testWidgets('Relative-width column with colspan will be allocated enough to fit intrinsic width', (WidgetTester tester) async {
    await tester.pumpWidget(Row(
      textDirection: TextDirection.ltr,
      children: [
        TablePane(
          columns: const <TablePaneColumn>[
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
          ],
          children: [
            TableRow(
              children: [
                const TableCell(
                  columnSpan: 2,
                  child: SizedBox(width: 100, height: 10),
                ),
                EmptyTableCell(),
              ],
            ),
          ],
        ),
      ],
    ));

    RenderTablePane renderObject = tester.renderObject<RenderTablePane>(find.byType(TablePane));
    expect(renderObject.size.width, 100);
    expect(renderObject.metrics.columnWidths, [50, 50]);
  });

  testWidgets('Relative-width column with colspan that exceeds width constraint will be sized down', (WidgetTester tester) async {
    await tester.pumpWidget(TablePane(
      columns: const <TablePaneColumn>[
        TablePaneColumn(width: RelativeTablePaneColumnWidth()),
        TablePaneColumn(width: RelativeTablePaneColumnWidth()),
      ],
      children: [
        TableRow(
          children: [
            const TableCell(
              columnSpan: 2,
              child: SizedBox(width: 1000, height: 10),
            ),
            EmptyTableCell(),
          ],
        ),
      ],
    ));

    RenderTablePane renderObject = tester.renderObject<RenderTablePane>(find.byType(TablePane));
    expect(renderObject.size.width, 800);
    expect(renderObject.metrics.columnWidths, [400, 400]);
  });

  testWidgets('todo', (WidgetTester tester) async {
    await tester.pumpWidget(Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 400),
        child: TablePane(
          columns: const <TablePaneColumn>[
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
          ],
          children: [
            TableRow(
              children: [
                const TableCell(
                  columnSpan: 2,
                  child: SizedBox(width: 100, height: 10),
                ),
                EmptyTableCell(),
              ],
            ),
          ],
        ),
      ),
    ));

    RenderTablePane renderObject = tester.renderObject<RenderTablePane>(find.byType(TablePane));
    expect(renderObject.size.width, 400);
    expect(renderObject.metrics.columnWidths, [200, 200]);
  });
}
