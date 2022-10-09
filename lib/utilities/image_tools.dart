import 'dart:io';
import 'dart:typed_data';

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
}
