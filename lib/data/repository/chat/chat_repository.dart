import 'package:flutter/foundation.dart';
import 'package:adda_time/core/interfaces/i_auth_repository.dart';
import 'package:adda_time/domain/models/chat/chat_user_model.dart';
import 'package:adda_time/core/interfaces/i_chat_repository.dart';
import 'package:adda_time/data/extensions/chat/chat_user_extensions.dart';
import 'package:adda_time/core/constants/enums/chat_failure_enum.dart';
import 'package:adda_time/core/config/env_config.dart';
import 'package:adda_time/core/services/chat_preferences_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Unit;
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc hide Unit;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:adda_time/core/security/e2ee.dart';
import 'package:adda_time/core/security/key_manager.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository implements IChatRepository {
  ChatRepository(this._authRepository, this._streamChatClient, this._firestore);

  final FirebaseFirestore _firestore;

  final IAuthRepository _authRepository;
  final StreamChatClient _streamChatClient;

  // Stream Chat API Secret is retrieved from environment configuration
  // No hardcoded secrets

  @override
  Stream<ChatUserModel> get chatAuthStateChanges {
    return _streamChatClient.state.currentUserStream.map(
      (OwnUser? user) => user?.toDomain() ?? ChatUserModel.empty(),
    );
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> disconnectUser() async {
    try {
      await _streamChatClient.disconnectUser();
      return right(unit);
    } catch (e) {
      debugPrint('Error disconnecting user: $e');
      return left(ChatFailureEnum.serverError);
    }
  }

  @override
  Stream<List<Channel>> get channelsThatTheUserIsIncluded {
    try {
      final currentUser = _streamChatClient.state.currentUser;
      if (currentUser == null) {
        return Stream.value([]);
      }

      return _streamChatClient
          .queryChannels(
            filter: sc.Filter.in_('members', [currentUser.id]),
          )
          .map((channels) => channels);
    } catch (e) {
      debugPrint('Error fetching channels: $e');
      return Stream.value([]);
    }
  }

  /// Generates a Stream Chat token for the given user ID
  String _generateToken(String userId) {
    // In production, token generation should happen on the server
    // This is only for development purposes
    
    // Get API secret from environment config
    final apiSecret = EnvConfig.instance.streamChatApiSecret;

    // Header
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));

    // Payload with the user ID
    final payload = {'user_id': userId};
    final encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));

    // Create signature
    final message = '$encodedHeader.$encodedPayload';
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmac.convert(utf8.encode(message));
    final signature = base64Url.encode(digest.bytes);

    // Return the JWT token
    return '$encodedHeader.$encodedPayload.$signature';
  }

  /// Generates random bytes for cryptographic operations
  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> connectTheCurrentUser() async {
    try {
      final signedInUserOption = await _authRepository.getSignedInUser();

      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );

      // Generate a token specific to this user
      final userToken = _generateToken(signedInUser.id);

      // Log token info for debugging
      debugPrint('Connecting user: ${signedInUser.id}');

      await _streamChatClient.connectUser(
        User(
          id: signedInUser.id,
          name: signedInUser.userName,
          image: signedInUser.photoUrl,
        ),
        userToken,
      );
      
      // Apply online status visibility setting
      final hideStatus = await ChatPreferencesService.instance.isOnlineStatusHidden();
      if (hideStatus && _streamChatClient.state.currentUser != null) {
        _streamChatClient.closeConnection();
      }
      
      return right(unit);
    } catch (e) {
      debugPrint('Error connecting user: $e');
      return left(ChatFailureEnum.connectionFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> createNewChannel({
    required List<String> listOfMemberIDs,
    required String channelName,
    required String channelImageUrl,
  }) async {
    try {
      if (listOfMemberIDs.isEmpty) {
        return left(ChatFailureEnum.channelCreateFailure);
      }

      final randomId = const Uuid().v1();

      // Generate a per-channel symmetric key (32 bytes)
      final channelKey = _randomBytes(32);

      // For E2EE, encrypt the channelKey for each member device using an
      // ephemeral X25519 key and the recipient device public key. The resulting
      // map is stored in channel metadata under 'e2ee_channel_keys'.
      final ephemeral = await crypto.X25519().newKeyPair();
      final ephemeralPub = (await ephemeral.extractPublicKey()).bytes;

      final Map<String, dynamic> e2eeChannelKeys = {};

      for (final memberId in listOfMemberIDs) {
        try {
          final userDoc = await _firestore.collection('users').doc(memberId).get();
          if (!userDoc.exists) continue;

          final deviceKeys = Map<String, dynamic>.from(userDoc.data()?['deviceKeys'] ?? {});
          if (deviceKeys.isEmpty) continue;

          final Map<String, dynamic> perDeviceMap = {};

          for (final entry in deviceKeys.entries) {
            final deviceId = entry.key;
            final pubBase64 = entry.value as String;
            final pubBytes = base64.decode(pubBase64);

            final recipientPub = crypto.SimplePublicKey(Uint8List.fromList(pubBytes), type: crypto.KeyPairType.x25519);

            // Derive shared secret using ephemeral private key and recipient public key
            final sharedSecret = await crypto.X25519().sharedSecretKey(
              keyPair: ephemeral,
              remotePublicKey: recipientPub,
            );

            // Derive an AEAD key from shared secret using HKDF
            final hkdf = crypto.Hkdf(
              hmac: crypto.Hmac.sha256(),
              outputLength: 32,
            );
            final derivedKey = await hkdf.deriveKey(
              secretKey: sharedSecret,
              info: utf8.encode('flutter_social_chat channel key'),
              nonce: [],
            );

            // Encrypt the channelKey with the derived key
            final aead = crypto.AesGcm.with128bits();
            final nonce = _randomBytes(12);
            final secretBox = await aead.encrypt(
              channelKey,
              secretKey: derivedKey,
              nonce: nonce,
            );

            perDeviceMap[deviceId] = {
              'ephemeral_pub': base64.encode(ephemeralPub),
              'ciphertext': base64.encode(secretBox.cipherText),
              'nonce': base64.encode(secretBox.nonce),
              'mac': base64.encode(secretBox.mac.bytes),
            };
          }

          if (perDeviceMap.isNotEmpty) {
            e2eeChannelKeys[memberId] = perDeviceMap;
          }
        } catch (e) {
          debugPrint('Error preparing E2EE keys for member $memberId: $e');
        }
      }

      await _streamChatClient.createChannel(
        'messaging',
        channelId: randomId,
        channelData: {
          'members': listOfMemberIDs,
          'name': channelName,
          'image': channelImageUrl,
          'created_at': DateTime.now().toIso8601String(),
          if (e2eeChannelKeys.isNotEmpty) 'e2ee_channel_keys': e2eeChannelKeys,
          'e2ee': e2eeChannelKeys.isNotEmpty,
        },
      );
      return right(unit);
    } catch (e) {
      debugPrint('Error creating channel: $e');
      return left(ChatFailureEnum.channelCreateFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> sendPhotoAsMessageToTheSelectedUser({
    required String channelId,
    required int sizeOfTheTakenPhoto,
    required String pathOfTheTakenPhoto,
  }) async {
    if (channelId.isEmpty || pathOfTheTakenPhoto.isEmpty) {
      return left(ChatFailureEnum.imageUploadFailure);
    }

    try {
      final randomMessageId = const Uuid().v1();

      final signedInUserOption = await _authRepository.getSignedInUser();
      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );
      final user = User(id: signedInUser.id);

      // Upload the image first
      final response = await _streamChatClient.sendImage(
        AttachmentFile(
          size: sizeOfTheTakenPhoto,
          path: pathOfTheTakenPhoto,
        ),
        channelId,
        'messaging',
      );

      // Create and send the message with the image
      final imageUrl = response.file;
      final image = Attachment(
        type: 'image',
        imageUrl: imageUrl,
      );

      final message = Message(
        user: user,
        id: randomMessageId,
        createdAt: DateTime.now(),
        attachments: [image],
      );

      await _streamChatClient.sendMessage(message, channelId, 'messaging');
      return right(unit);
    } catch (e) {
      debugPrint('Error sending photo message: $e');
      return left(ChatFailureEnum.imageUploadFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> sendTextMessage({
    required String channelId,
    required String text,
  }) async {
    if (channelId.isEmpty || text.isEmpty) {
      return left(ChatFailureEnum.serverError);
    }

    try {
      final randomMessageId = const Uuid().v1();

      final signedInUserOption = await _authRepository.getSignedInUser();
      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );
      final user = User(id: signedInUser.id);

      // Obtain channel to fetch e2ee channel key metadata
      final channel = _streamChatClient.channel('messaging', id: channelId);
      await channel.watch();

      // Attempt to recover channel symmetric key for this device
      final keyManager = KeyManager();
      final deviceId = await keyManager.getOrCreateDeviceId();
      final channelMeta = channel.extraData;
      Uint8List? channelSymKey;

      try {
        if (channelMeta['e2ee'] == true && channelMeta['e2ee_channel_keys'] != null) {
          final e2eeMap = Map<String, dynamic>.from(channelMeta['e2ee_channel_keys'] as Map);
          final signedInUserOption = await _authRepository.getSignedInUser();
          final signedInUser = signedInUserOption.fold(() => throw Exception('User not authenticated'), (u) => u);
          final myUserId = signedInUser.id;

          final userEntries = e2eeMap[myUserId];
          if (userEntries != null) {
            final deviceEntry = (userEntries as Map<String, dynamic>)[deviceId];
            if (deviceEntry != null) {
              // Decrypt encrypted channel key using our X25519 keypair
              final ephemeralPub = base64.decode(deviceEntry['ephemeral_pub'] as String);
              final ciphertext = base64.decode(deviceEntry['ciphertext'] as String);
              final nonce = base64.decode(deviceEntry['nonce'] as String);
              final mac = base64.decode(deviceEntry['mac'] as String);

              final myKeyPairData = await keyManager.getOrCreateKeyPairData();
              final myKeyPair = crypto.SimpleKeyPairData(
                myKeyPairData.bytes,
                publicKey: crypto.SimplePublicKey(myKeyPairData.publicKey.bytes, type: crypto.KeyPairType.x25519),
                type: crypto.KeyPairType.x25519,
              );

              final sharedSecret = await crypto.X25519().sharedSecretKey(
                keyPair: myKeyPair,
                remotePublicKey: crypto.SimplePublicKey(Uint8List.fromList(ephemeralPub), type: crypto.KeyPairType.x25519),
              );

              final hkdf = crypto.Hkdf(
                hmac: crypto.Hmac.sha256(),
                outputLength: 32,
              );
              final derivedKey = await hkdf.deriveKey(
                secretKey: sharedSecret,
                info: utf8.encode('flutter_social_chat channel key'),
                nonce: [],
              );

              final aead = crypto.AesGcm.with128bits();
              final secretBox = crypto.SecretBox(
                ciphertext,
                nonce: Uint8List.fromList(nonce),
                mac: crypto.Mac(mac),
              );

              final decrypted = await aead.decrypt(secretBox, secretKey: derivedKey);
              channelSymKey = Uint8List.fromList(decrypted);
            }
          }
        }
      } catch (e) {
        debugPrint('Warning: could not recover channel key for encryption: $e');
      }

      // If channel symmetric key recovered, use it to encrypt message; else fall back to device-local AES
      Map<String, dynamic> payload;
      if (channelSymKey != null) {
        final aead = crypto.AesGcm.with128bits();
        final secretKey = crypto.SecretKey(channelSymKey);
        final nonce = _randomBytes(12);
        final secretBox = await aead.encrypt(utf8.encode(text), secretKey: secretKey, nonce: nonce);
        payload = {
          'ciphertext': base64.encode(secretBox.cipherText),
          'nonce': base64.encode(secretBox.nonce),
          'mac': base64.encode(secretBox.mac.bytes),
          'version': '2',
        };
      } else {
        final e2ee = E2ee();
        payload = await e2ee.encryptUtf8(text);
      }

      final message = Message(
        user: user,
        id: randomMessageId,
        createdAt: DateTime.now(),
        text: '',
        extraData: {
          'e2ee': true,
          'e2ee_payload': payload,
          'e2ee_version': payload['version'] ?? '1',
        },
      );

      await _streamChatClient.sendMessage(message, channelId, 'messaging');
      return right(unit);
    } catch (e) {
      debugPrint('Error sending text message: $e');
      return left(ChatFailureEnum.serverError);
    }
  }

  @override
  Future<String?> tryDecryptMessage(Message message) async {
    try {
      final extra = message.extraData;
      if (extra['e2ee'] != true) return null;

      final payloadObj = extra['e2ee_payload'];
      if (payloadObj == null) return null;
      final payload = Map<String, dynamic>.from(payloadObj as Map);

      // If version 2, it's encrypted with channel symmetric key
      final version = extra['e2ee_version'] ?? (payload['version'] ?? '1');
      if (version == '2') {
        // Version 2 requires channel context which is not available in tryDecryptMessage
        // For now, fallback to device-local decryption
        debugPrint('Version 2 decryption not yet supported in tryDecryptMessage');
        // Fall through to version 1 decryption
      }

      // Fallback: device-local AES-GCM encryption (version 1)
      final e2ee = E2ee();
      final decrypted = await e2ee.decryptUtf8(Map<String, dynamic>.from(payload));
      if (decrypted != null) return decrypted;

      return null;
    } catch (e) {
      debugPrint('Error decrypting message: $e');
      return null;
    }
  }
}
