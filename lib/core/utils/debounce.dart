import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility to debounce fast successive actions (e.g. search keystrokes).
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
