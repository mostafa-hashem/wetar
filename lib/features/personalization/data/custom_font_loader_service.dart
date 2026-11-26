import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/logging/app_logger.dart';
import 'package:wetar/core/storage/cache_manager.dart';

/// Validates user-selected `.ttf` / `.otf` font files in an isolate, stores them
/// in app-private storage, and loads them dynamically via Flutter's [FontLoader].
class CustomFontLoaderService {
  CustomFontLoaderService(this._cacheManager);

  final CacheManager _cacheManager;
  static const int maxFontBytes = 15 * 1024 * 1024;
  static const String importedFamilyPrefix = 'WetarUserFont';

  Future<String?> importAndRegisterFont(String sourceFilePath) async {
    try {
      await _cacheManager.init();
      final source = File(sourceFilePath);
      if (!source.existsSync()) return null;

      final bytes = await source.readAsBytes();
      final valid = await Isolate.run(() => isValidFontBinary(bytes));
      if (!valid) return null;

      final ext = p.extension(sourceFilePath).toLowerCase();
      final safeExt = ext == '.otf' ? '.otf' : '.ttf';
      final fileName =
          'user_font_${DateTime.now().millisecondsSinceEpoch}$safeExt';
      final destPath = p.join(_cacheManager.fontsDir.path, fileName);
      await File(destPath).writeAsBytes(bytes, flush: true);

      final familyName =
          '${importedFamilyPrefix}_${p.basenameWithoutExtension(fileName)}';
      await _registerFontBytes(familyName, bytes);
      AppLogger.info('CustomFontLoader', 'Registered custom font $familyName');
      return familyName;
    } catch (e, st) {
      AppLogger.error(
        'CustomFontLoader',
        'Failed importing font',
        errorObj: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Restores any previously imported custom font on cold start.
  Future<void> reloadStoredFontIfNeeded(String? importedFamily) async {
    if (importedFamily == null ||
        !importedFamily.startsWith(importedFamilyPrefix)) {
      return;
    }
    try {
      await _cacheManager.init();
      if (!_cacheManager.fontsDir.existsSync()) return;
      final stem = importedFamily.replaceFirst('${importedFamilyPrefix}_', '');
      await for (final entity in _cacheManager.fontsDir.list()) {
        if (entity is File && p.basenameWithoutExtension(entity.path) == stem) {
          final bytes = await entity.readAsBytes();
          if (await Isolate.run(() => isValidFontBinary(bytes))) {
            await _registerFontBytes(importedFamily, bytes);
          }
          return;
        }
      }
    } catch (e) {
      AppLogger.warn('CustomFontLoader', 'Could not reload font: $e');
    }
  }

  Future<void> _registerFontBytes(String family, Uint8List bytes) async {
    final loader = FontLoader(family);
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  static bool isValidFontBinary(Uint8List bytes) {
    if (bytes.length < 12 || bytes.length > maxFontBytes) return false;
    final b0 = bytes[0];
    final b1 = bytes[1];
    final b2 = bytes[2];
    final b3 = bytes[3];
    // TrueType (0x00010000 or 'true') or OpenType ('OTTO') or TrueType Collection ('ttcf').
    final isTrueType = b0 == 0x00 && b1 == 0x01 && b2 == 0x00 && b3 == 0x00;
    final isAppleTrue = b0 == 0x74 && b1 == 0x72 && b2 == 0x75 && b3 == 0x65;
    final isOpenType = b0 == 0x4F && b1 == 0x54 && b2 == 0x54 && b3 == 0x4F;
    final isTtc = b0 == 0x74 && b1 == 0x74 && b2 == 0x63 && b3 == 0x66;
    return isTrueType || isAppleTrue || isOpenType || isTtc;
  }
}
