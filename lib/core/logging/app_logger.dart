import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Offline rotating diagnostic logger backed by an app-private log file.
class AppLogger {
  AppLogger._();

  static const int _maxBytes = 1024 * 1024;
  static const int _maxMemoryLines = 300;

  static File? _logFile;
  static final List<String> _recentLines = <String>[];
  static final StreamController<String> _lineStream =
      StreamController<String>.broadcast();
  static Future<void> _writeChain = Future<void>.value();

  static Stream<String> get linesStream => _lineStream.stream;
  static List<String> get recentLines =>
      List<String>.unmodifiable(_recentLines);

  /// Initializes the log file location inside app support directory.
  static Future<void> init() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final logsDir = Directory(p.join(dir.path, 'logs'));
      if (!logsDir.existsSync()) {
        logsDir.createSync(recursive: true);
      }
      _logFile = File(p.join(logsDir.path, 'wetar_diagnostics.log'));
      await _rotateIfOversized();
    } catch (_) {
      // Fallback safely to in-memory buffer when unit-testing without path_provider.
      _logFile = null;
    }
  }

  /// Installs global Flutter and platform error hooks writing to the local log.
  static void installGlobalErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      error(
        'FlutterError',
        details.exceptionAsString(),
        errorObj: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (Object err, StackTrace stack) {
      error(
        'PlatformDispatcher',
        err.toString(),
        errorObj: err,
        stackTrace: stack,
      );
      return true;
    };
  }

  static void info(String scope, String message) {
    _append('INFO', scope, message);
  }

  static void warn(String scope, String message) {
    _append('WARN', scope, message);
  }

  static void error(
    String scope,
    String message, {
    Object? errorObj,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer(message);
    if (errorObj != null) {
      buffer.write(' | error=$errorObj');
    }
    if (stackTrace != null) {
      final stackLines = stackTrace.toString().split('\n').take(8).join(' <- ');
      buffer.write(' | stack=$stackLines');
    }
    _append('ERROR', scope, buffer.toString());
  }

  static void _append(String level, String scope, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final formatted = '[$timestamp][$level][$scope] $message';
    _recentLines.add(formatted);
    if (_recentLines.length > _maxMemoryLines) {
      _recentLines.removeAt(0);
    }
    if (!_lineStream.isClosed) {
      _lineStream.add(formatted);
    }
    final file = _logFile;
    if (file == null) return;
    _writeChain = _writeChain.then((_) async {
      try {
        await _rotateIfOversized();
        await file.writeAsString(
          '$formatted\n',
          mode: FileMode.append,
          flush: false,
        );
      } catch (_) {
        // Ignore transient write errors while keeping in-memory ring buffer intact.
      }
    });
  }

  static Future<void> _rotateIfOversized() async {
    final file = _logFile;
    if (file == null || !file.existsSync()) return;
    final len = await file.length();
    if (len <= _maxBytes) return;
    final backup = File('${file.path}.prev');
    if (backup.existsSync()) {
      await backup.delete();
    }
    await file.rename(backup.path);
  }

  static Future<String> readFullLog() async {
    final file = _logFile;
    if (file == null || !file.existsSync()) {
      return _recentLines.join('\n');
    }
    try {
      return await file.readAsString();
    } catch (_) {
      return _recentLines.join('\n');
    }
  }

  static String? get logFilePath => _logFile?.path;

  static Future<void> clearLogs() async {
    _recentLines.clear();
    final file = _logFile;
    if (file != null && file.existsSync()) {
      await file.writeAsString('', flush: true);
    }
  }
}
