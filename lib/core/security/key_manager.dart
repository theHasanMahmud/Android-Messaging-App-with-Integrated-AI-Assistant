import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart' as crypto;

/// Lightweight KeyManager stub.
/// This implementation only generates a random per-device public value and
/// publishes it to Firestore to satisfy existing app flows. It does NOT
/// implement real X25519 key agreement. Replace with a proper crypto
/// implementation when ready.
class KeyManager {
  static const _deviceIdKey = 'e2ee_device_id_v1';
  static const _publicKeyKey = 'e2ee_public_v1';
  static const _privateKeyKey = 'e2ee_private_v1';
  final _storage = const FlutterSecureStorage();

  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null) return existing;
    final id = _randomId();
    await _storage.write(key: _deviceIdKey, value: id);
    return id;
  }

  Future<String> getOrCreatePublicKeyBase64() async {
    final existing = await _storage.read(key: _publicKeyKey);
    if (existing != null) return existing;
    final bytes = _randomBytes(32);
    final b64 = base64.encode(bytes);
    await _storage.write(key: _publicKeyKey, value: b64);
    return b64;
  }

  Future<crypto.SimpleKeyPairData> getOrCreateKeyPairData() async {
    // Check if we already have a key pair
    final existingPrivate = await _storage.read(key: _privateKeyKey);
    final existingPublic = await _storage.read(key: _publicKeyKey);
    
    if (existingPrivate != null && existingPublic != null) {
      final privateBytes = base64.decode(existingPrivate);
      final publicBytes = base64.decode(existingPublic);
      return crypto.SimpleKeyPairData(
        privateBytes,
        publicKey: crypto.SimplePublicKey(publicBytes, type: crypto.KeyPairType.x25519),
        type: crypto.KeyPairType.x25519,
      );
    }

    // Generate new key pair
    final keyPair = await crypto.X25519().newKeyPair();
    final privateKey = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    
    // Store for future use
    await _storage.write(key: _privateKeyKey, value: base64.encode(privateKey));
    await _storage.write(key: _publicKeyKey, value: base64.encode(publicKey.bytes));
    
    return crypto.SimpleKeyPairData(
      privateKey,
      publicKey: publicKey,
      type: crypto.KeyPairType.x25519,
    );
  }

  Future<void> publishPublicKeyToFirestore(FirebaseFirestore firestore, String uid) async {
    final deviceId = await getOrCreateDeviceId();
    final keyPairData = await getOrCreateKeyPairData();
    final pubBase64 = base64.encode(keyPairData.publicKey.bytes);

    final userDoc = firestore.collection('users').doc(uid);
    await userDoc.set({
      'deviceKeys': {deviceId: pubBase64},
    }, SetOptions(merge: true),);
  }

  String _randomId() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return Uint8List.fromList(bytes);
  }
}
