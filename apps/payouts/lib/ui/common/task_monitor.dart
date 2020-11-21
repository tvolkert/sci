import 'dart:async';

import 'package:flutter/material.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class TaskMonitor extends StatefulWidget {
  const TaskMonitor({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return TaskMonitorState();
  }

  /// Returns the data from the closest [TaskMonitor] instance that encloses
  /// the given context.
  ///
  /// This is guaranteed to be non-null (or throw).
  static TaskMonitorState of(BuildContext context) {
    _TaskMonitorScope? scope = context.dependOnInheritedWidgetOfExactType<_TaskMonitorScope>();
    assert(() {
      if (scope == null) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: 'TaskMonitor not found in ancestry',
          stack: StackTrace.current,
          library: 'payouts',
        ));
      }
      return true;
    }());
    return scope!.taskMonitorState;
  }
}

class TaskMonitorState extends State<TaskMonitor> {
  /// Whether an unfinished task is currently being monitored.
  ///
  /// When this is true, it is an error to monitor a new task using [monitor].
  bool _isActive = false;
  bool get isActive => _isActive;

  /// Monitors the specified [future], providing UI feedback to the user on the
  /// state of the future.
  ///
  /// It is an error to call this if a monitored task is already pending (i.e.
  /// if [isActive] returns true).
  ///
  /// Returns a future that completes with the same result as [future], but
  /// only completes once the UI has finished notifying the user of the
  /// result of the future.
  ///
  /// Callers are responsible for handling errors generated by the returned
  /// future. Failure to do so will result in the error being an unhandled
  /// error (potentially propagating all the way to the Zone's
  /// [Zone.handleUncaughtError] callback).
  ///
  /// The [future], [inProgressMessage], and [completedMessage] arguments must
  /// all be non-null.
  Future<T> monitor<T>({
    required Future<T> future,
    required String inProgressMessage,
    required String completedMessage,
  }) {
    assert(() {
      if (isActive) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: 'TaskMonitor already has a monitored task in progress',
          stack: StackTrace.current,
          library: 'payouts',
        ));
        return false;
      }
      return true;
    }());

    setState(() {
      _isActive = true;
    });

    _FutureCompletion<T>? completion;
    future.then((T value) {
      completion = _FutureCompletion.value(value);
    }).catchError((Object error, StackTrace stackTrace) {
      completion = _FutureCompletion.error(error, stackTrace);
    });

    final Completer<T> completer = Completer<T>();
    final ThemeData themeData = Theme.of(context);
    final TextStyle textStyle = DefaultTextStyle.of(context).style;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'TaskMonitor barrier',
      barrierColor: const Color(0x00000000),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return TaskStatus<T>(
          future: future,
          inProgressMessage: inProgressMessage,
          completedMessage: completedMessage,
          themeData: themeData,
          textStyle: textStyle,
        );
      },
    ).then<void>((void _) {
      assert(() {
        if (completion == null) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: 'TaskMonitor\'s dialog was closed before the monitored future had completed',
            stack: StackTrace.current,
            library: 'payouts',
          ));
          return false;
        }
        return true;
      }());
      completion!.complete(completer);
    }).catchError((dynamic error, StackTrace stackTrace) {
      completer.completeError(error, stackTrace);
    }).whenComplete(() {
      setState(() {
        _isActive = false;
      });
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return _TaskMonitorScope(
      taskMonitorState: this,
      child: widget.child,
    );
  }
}

class _FutureCompletion<T> {
  const _FutureCompletion.value([this.value]) : error = null, stackTrace = null;
  const _FutureCompletion.error(Object this.error, StackTrace this.stackTrace) : value = null;

  final T? value;
  final Object? error;
  final StackTrace? stackTrace;

  void complete(Completer<T> completer) {
    if (error != null) {
      completer.completeError(error!, stackTrace);
    } else {
      completer.complete(value);
    }
  }
}

class _TaskMonitorScope extends InheritedWidget {
  const _TaskMonitorScope({
    Key? key,
    required this.taskMonitorState,
    required Widget child,
  }) : super(key: key, child: child);

  final TaskMonitorState taskMonitorState;

  @override
  bool updateShouldNotify(_TaskMonitorScope old) {
    return taskMonitorState.isActive != old.taskMonitorState.isActive;
  }
}

class TaskStatus<T> extends StatefulWidget {
  const TaskStatus({
    Key? key,
    required this.future,
    required this.inProgressMessage,
    required this.completedMessage,
    required this.themeData,
    required this.textStyle,
  })  : super(key: key);

  final Future<T> future;
  final String inProgressMessage;
  final String completedMessage;
  final ThemeData themeData;
  final TextStyle textStyle;

  @override
  _TaskStatusState<T> createState() => _TaskStatusState<T>();
}

enum _Status {
  /// The task is still running.
  inProgress,

  /// The task completed successfully.
  success,

  /// The task completed with an error.
  failure,
}

class _TaskStatusState<T> extends State<TaskStatus<T>> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  _Status _status = _Status.inProgress;
  String? _errorMessage;

  static const Duration _delayBeforeFade = Duration(milliseconds: 1750);
  static const Duration _fadeDuration = Duration(milliseconds: 265);
  static final Animatable<double> _fadeTween = Tween<double>(begin: 1, end: 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );
    _fadeAnimation = _controller.drive(_fadeTween);
    _monitorFuture();
  }

  @override
  void didUpdateWidget(TaskStatus<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.future != oldWidget.future) {
      // There's no way to un-listen to the old future, so we handle that case
      // in [_monitorFuture] by checking if the future on which we were
      // listening is still the widget's future.
      _monitorFuture();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _monitorFuture() async {
    Future<T> future = widget.future;
    _Status status;
    String? errorMessage;
    try {
      await future;
      status = _Status.success;
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        context: ErrorDescription('while waiting for a monitored future of type $T'),
      ));
      errorMessage = '$error';
      status = _Status.failure;
    }

    if (future != widget.future || !mounted) {
      // Our original context is no longer valid.
      return;
    }

    setState(() {
      _status = status;
      _errorMessage = errorMessage;
    });

    await Future<void>.delayed(_delayBeforeFade * (status == _Status.success ? 1 : 5));
    await _controller.forward();

    // This triggers the completion of the future that was returned in the API.
    Navigator.of(context).pop<void>();
  }

  Widget _graphicForStatus() {
    switch (_status) {
      case _Status.inProgress:
        return pivot.ActivityIndicator(
          color: const Color(0xffffffff),
        );
      case _Status.success:
        return CustomPaint(
          size: Size.square(80),
          painter: _CheckmarkImagePainter(),
        );
      case _Status.failure:
        return CustomPaint(
          size: Size.square(128),
          painter: _ExclamationImagePainter(),
        );
    }
  }

  String _textForStatus() {
    switch (_status) {
      case _Status.inProgress:
        return widget.inProgressMessage;
      case _Status.success:
        return widget.completedMessage;
      case _Status.failure:
        return _errorMessage!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: Align(
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedSize(
            curve: Curves.elasticOut,
            duration: const Duration(milliseconds: 250),
            vsync: this,
            child: SizedBox(
              width: _status == _Status.failure ? 400 : 200,
              height: _status == _Status.failure ? 400 : 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 128,
                        height: 128,
                        child: Align(
                          alignment: Alignment.center,
                          child: _graphicForStatus(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _textForStatus(),
                        textAlign: TextAlign.center,
                        style: widget.textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xffffffff),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckmarkImagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(5, 50)
      ..lineTo(10, 45)
      ..lineTo(25, 60)
      ..lineTo(70, 15)
      ..lineTo(75, 20)
      ..lineTo(25, 70)
      ..close();
    Paint paint = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkImagePainter oldDelegate) => false;
}

class _ExclamationImagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(64, 104)
      ..cubicTo(112, -24, 16, -24, 64, 104)
      ..close()
      ..addOval(Rect.fromLTWH(56, 112, 16, 16));
    Paint paint = Paint()
      ..color = const Color(0xffcc0000)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ExclamationImagePainter oldDelegate) => false;
}
