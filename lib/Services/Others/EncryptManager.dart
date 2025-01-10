/*import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptManager {
  static final _key = encrypt.Key.fromUtf8('3jd9F82kd4F93jfK2fj38WlFjV3P2jfL');
  static final _iv = encrypt.IV.fromUtf8('F93k2j8D3jfK29Wj');

  /// Encrypts a plain text string and returns the encrypted value as a Base64 string.
  static String encryptText(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts a Base64 encrypted string and returns the plain text.
  static String decryptText(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}

NOT USING NOW
 */