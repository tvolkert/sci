import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/user.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class AddTimesheetIntent extends Intent {
  const AddTimesheetIntent({this.context});

  final BuildContext context;
}

class AddTimesheetAction extends ContextAction<AddTimesheetIntent> {
  AddTimesheetAction._();

  static final AddTimesheetAction instance = AddTimesheetAction._();

  @override
  Future<void> invoke(AddTimesheetIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await AddTimesheetSheet.open(context: context);
    print('TODO: add timesheet');
  }
}

class AddTimesheetSheet extends StatefulWidget {
  const AddTimesheetSheet({Key key}) : super(key: key);

  @override
  _AddTimesheetSheetState createState() => _AddTimesheetSheetState();

  static Future<void> open({BuildContext context}) {
    return pivot.Sheet.open<void>(
      context: context,
      content: AddTimesheetSheet(),
    );
  }
}

class _AddTimesheetSheetState extends State<AddTimesheetSheet> {
  List<Map<String, dynamic>> _assignments;

  @override
  void initState() {
    super.initState();
    final Uri url = Server.uri(Server.userAssignmentsUrl);
    UserBinding.instance.user.authenticate().get(url).then((http.Response response) {
      if (!mounted) {
        return;
      }
      if (response.statusCode == HttpStatus.ok) {
        setState(() {
          final List<dynamic> data = json.decode(response.body);
          _assignments = data.cast<Map<String, dynamic>>();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pivot.Border(
            backgroundColor: const Color(0xffffffff),
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: pivot.TablePane(
                verticalSpacing: 6,
                horizontalSpacing: 6,
                columns: [
                  pivot.TablePaneColumn(
                    width: pivot.IntrinsicTablePaneColumnWidth(),
                  ),
                  pivot.TablePaneColumn(
                    width: pivot.RelativeTablePaneColumnWidth(),
                  ),
                ],
                children: [
                  if (_assignments != null) pivot.TableRow(
                    children: [
                      Text('Program:'),
                      pivot.ListButton(
                        length: _assignments.length,
                        builder: ({BuildContext context, int index}) {
                          return Text(_assignments[index][Keys.name]);
                        },
                        itemBuilder: ({
                          BuildContext context,
                          int index,
                          bool isSelected,
                          bool isHighlighted,
                          bool isDisabled,
                        }) {
                          TextStyle style = DefaultTextStyle.of(context).style;
                          if (isSelected) {
                            style = style.copyWith(color: const Color(0xffffffff));
                          }
                          return Text(_assignments[index][Keys.name], style: style);
                        },
                      ),
                    ],
                  ),
                  pivot.TableRow(
                    children: [
                      Text('Charge Number:'),
                      pivot.TextInput(
                        backgroundColor: const Color(0xfff7f5ee),
                      ),
                    ],
                  ),
                  pivot.TableRow(
                    children: [
                      Text('Requestor (Client):'),
                      pivot.TextInput(
                        backgroundColor: const Color(0xfff7f5ee),
                      ),
                    ],
                  ),
                  pivot.TableRow(
                    children: [
                      Text('Task:'),
                      Row(
                        children: [
                          Expanded(
                            child: pivot.TextInput(
                              backgroundColor: const Color(0xfff7f5ee),
                            ),
                          ),
                          Text('(optional)'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 6),
              pivot.CommandPushButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
