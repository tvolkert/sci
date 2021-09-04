import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'first_frame_mixin.dart';

abstract class AppBindingBase with FirstFrameMixin {
  /// Default abstract constructor for application bindings.
  ///
  /// First calls [initInstances] to have bindings initialize their
  /// instance pointers and other state.
  AppBindingBase() {
    developer.Timeline.startSync('App initialization');

    assert(!_debugInitialized);
    initInstances();
    assert(_debugInitialized);

    developer.postEvent('Payouts.AppInitialization', <String, String>{});
    developer.Timeline.finishSync();
  }

  static bool _debugInitialized = false;

  /// The initialization method. Subclasses override this method to hook into
  /// the app. Subclasses must call `super.initInstances()`.
  ///
  /// By convention, if the service is to be provided as a singleton, it should
  /// be exposed as `MixinClassName.instance`, a static getter that returns
  /// `MixinClassName._instance`, a static field that is set by
  /// `initInstances()`.
  @protected
  @mustCallSuper
  void initInstances() {
    assert(!_debugInitialized);
    assert(() {
      _debugInitialized = true;
      return true;
    }());
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance!.scheduleFrameCallback((Duration timeStamp) {
      handleFirstFrame(timeStamp);
    });
  }

  @override
  String toString() => '<${objectRuntimeType(this, 'AppBindingBase')}>';
}
