import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as system;
import 'package:haptic_feedback/haptic_feedback.dart' as hfp;

class Haptics{
  Haptics._();
  static bool _enabled = true;
  static bool get enabled => _enabled;
  static void setEnabled(bool v) {
    _enabled = v;
  }
  static void light(){
    if (!enabled) return;
    if (_isIOS) {
      _safe(() => hfp.Haptics.vibrate(hfp.HapticsType.light));
    } else if (_isAndroid) {
      _safe(() => system.HapticFeedback.lightImpact());
    }
  }
  static void medium() {
    if (!enabled) return;
    if (_isIOS) {
      _safe(() => hfp.Haptics.vibrate(hfp.HapticsType.medium));
    } else if (_isAndroid) {
      _safe(() => system.HapticFeedback.mediumImpact());
    }
  }
  static void soft() {
    if (!enabled) return;
    if (_isIOS) {
      _safe(() => hfp.Haptics.vibrate(hfp.HapticsType.soft));
    } else if (_isAndroid) {
      // Closest built-in equivalent to a very gentle tap
      _safe(() => system.HapticFeedback.selectionClick());
    }
  }
  static void drawerPulse() {
    if (!enabled) return;
    if (_isIOS) {
      _safe(() => hfp.Haptics.vibrate(hfp.HapticsType.soft));
    } else if (_isAndroid) {
      _safe(() => system.HapticFeedback.selectionClick());
    }
  }
  static void cancel() {
    /* no-op */
  }

  static bool get _isIOS => !kIsWeb && defaultTargetPlatform==TargetPlatform.iOS;
  static bool get _isAndroid => !kIsWeb && defaultTargetPlatform==TargetPlatform.android;
  static void _safe(Future<void> Function() action){
    if (kIsWeb) return;
    try {
      action();
    } catch (_) {}
  }
}