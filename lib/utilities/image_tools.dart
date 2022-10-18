import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import '../devtools/logger.dart';

import 'settings_manager.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ImageTools {
  /// returns null on failure
  static Future<Uint8List?> getImageBytes(String imageFilePath) async {
    if (imageFilePath.isNotEmpty) {
      try {
        File imageFile = File(imageFilePath);
        Uint8List projectGraphicBytes = await imageFile.readAsBytes();
        if (projectGraphicBytes.isNotEmpty) return projectGraphicBytes;
      } catch (e) {
        // empty
      }
    }

    return null;
  }

  static Future<Uint8List?> getCachedImageBytes(String serverGraphicPath) async {
    String sourceFilePath = SettingsManager.getFolder() + 'graphicCache/' + serverGraphicPath;

    try {
      File source = File(sourceFilePath);
      if (!(await source.exists())) return null;
      Uint8List imageBytes = await source.readAsBytes();
      return imageBytes;
    } catch (e) {
      Logger.print('failed to get cached image bytes | exception: \'${e.toString()}\'');
    }

    return null;
  }

  static Future<bool> cacheImageBytes(String serverGraphicPath, Uint8List imageBytes) async {
    String destFilePath = SettingsManager.getFolder() + 'graphicCache/' + serverGraphicPath;
    Logger.print('cache image bytes | dest file path: \'$destFilePath\'');

    try {
      String folder = path.dirname(destFilePath);

      if (!(await Directory(folder).exists())) {
        await Directory(folder).create(recursive: true);
      }

      File dest = File(destFilePath);
      List<int> byteList = imageBytes.toList();
      await dest.writeAsBytes(byteList, flush: true);
      return true;
    } catch (e) {
      Logger.print('failed to cache image bytes | exception: \'${e.toString()}\'');
    }

    return false;
  }
}
