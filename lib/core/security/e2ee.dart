import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple AES-GCM helper using the `encrypt` package for compatibility.
class E2ee {
  static const _storageKey = 'e2ee_aes_key_v1';
  final _storage = const FlutterSecureStorage();

  Future<Uint8List> _getOrCreateKey() async {
    final existing = await _storage.read(key: _storageKey);
    if (existing != null) return base64.decode(existing);
    final secret = _randomBytes(32);
    await _storage.write(key: _storageKey, value: base64.encode(secret));
    return secret;
  }

  Uint8List _randomBytes(int len) {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(len, (_) => rnd.nextInt(256)));
  }

  Future<Map<String, dynamic>> encryptUtf8(String plaintext) async {
    final keyBytes = await _getOrCreateKey();
    final key = encrypt_pkg.Key(keyBytes);
    final ivBytes = _randomBytes(12);
    final iv = encrypt_pkg.IV(ivBytes);
    final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    return {
      'v': 1,
      'iv': base64.encode(iv.bytes),
      'ct': base64.encode(encrypted.bytes),
    };
  }

  Future<String?> decryptUtf8(Map<String, dynamic> payload) async {
    try {
      final keyBytes = await _getOrCreateKey();
      final key = encrypt_pkg.Key(keyBytes);
      final iv = encrypt_pkg.IV(base64.decode(payload['iv'] as String));
      final ct = base64.decode(payload['ct'] as String);
      final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.gcm));
      final encrypted = encrypt_pkg.Encrypted(Uint8List.fromList(ct));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return null;
    }
  }
}
    final rnd = Random.secure();
