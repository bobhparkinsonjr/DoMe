import 'package:encrypt/encrypt.dart';

import '../config/app_encryption_settings.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppEncryptor {
  static String encryptPasswordString(String message, String password) {
    if (message.isEmpty) return '';
    final key = Key.fromUtf8(_getPasswordKey(password));
    final iv = IV.fromLength(kAppEncryptIVLength);
    return Encrypter(AES(key)).encrypt(message, iv: iv).base64;
  }

  static String encryptString(String message) {
    return encryptPasswordString(message, kAppEncryptionGeneralKey);
  }

  static String decryptPasswordString(String encryptedMessage, String password) {
    if (encryptedMessage.isEmpty) return '';
    final key = Key.fromUtf8(_getPasswordKey(password));
    final iv = IV.fromLength(kAppEncryptIVLength);
    return Encrypter(AES(key)).decrypt(Encrypted.from64(encryptedMessage), iv: iv);
  }

  static String decryptString(String message) {
    return decryptPasswordString(message, kAppEncryptionGeneralKey);
  }

  static String _getPasswordKey(String password) {
    if (password.length > 32) return password.substring(0, 32);
    return password.padRight(32, ' ');
  }
}
