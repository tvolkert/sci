// @dart=2.9

import 'package:flutter/painting.dart';

const HSVColor _kDebugDefaultRepaintColor = HSVColor.fromAHSV(0.4, 60.0, 1.0, 1.0);

/// Overlay a rotating set of colors when rebuilding table cells in checked
/// mode.
///
/// See also:
///
///  * [debugRepaintRainbowEnabled], a similar flag for visualizing layer
///    repaints.
///  * [BasicTableView], [TableView], and [ScrollableTableView], which look
///    for this flag when running in debug mode.
bool debugPaintTableCellBuilds = false;

/// The current color to overlay when repainting a table cell build.
HSVColor debugCurrentTableCellColor = _kDebugDefaultRepaintColor;

/// Overlay a rotating set of colors when rebuilding list items in checked
/// mode.
///
/// See also:
///
///  * [debugRepaintRainbowEnabled], a similar flag for visualizing layer
///    repaints.
///  * [BasicListView] and [ListView], which look for this flag when running in
///    debug mode.
bool debugPaintListItemBuilds = false;

/// The current color to overlay when repainting a list item build.
HSVColor debugCurrentListItemColor = _kDebugDefaultRepaintColor;
