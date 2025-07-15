import 'dart:developer';

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionServices {
  // AES algorithm parameters
  final _key = encrypt.Key.fromUtf8('ABCDEFabcdef1234567890!@#\$%^&*()');
  late final encrypt.Encrypter encrypter;
  late encrypt.IV iv;
  EncryptionServices() {
    encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }
  // Encrypt message content
  String encryptMessage(String plainText) {
    iv = encrypt.IV.fromSecureRandom(16); // New IV for each message
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // log("Original message: $plainText");
    // log("Encrypted message: ${encrypted.base64}");
    // log("IV used: ${iv.base64}");`
    return encrypted.base64;
  }

  // Convert a Base64 string to Encrypted
  encrypt.Encrypted _base64ToEncrypted(String base64Text) {
    return encrypt.Encrypted.fromBase64(base64Text);
  }

  // Decrypt message content
  String decryptMessage(String encryptedText, String ivText) {
    try {
      final encrypted = _base64ToEncrypted(encryptedText);
      iv = encrypt.IV.fromBase64(ivText);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      // log("Decrypted message: $decrypted");
      // log("IV used: ${iv.base64}");
      return decrypted;
    } catch (e) {
      log('Decryption error: $e');
      return 'Decryption failed';
    }
  }
}
