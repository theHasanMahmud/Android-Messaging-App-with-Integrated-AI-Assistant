// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Class responsible for loading and managing environment variables
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._();
  static EnvConfig get instance => _instance;

  EnvConfig._();

  bool _initialized = false;

  /// Stream Chat API key from .env file
  String get streamChatApiKey => _getEnvVariable('STREAM_CHAT_API_KEY');

  /// Stream Chat API secret from .env file
  String get streamChatApiSecret => _getEnvVariable('STREAM_CHAT_API_SECRET');

  /// OpenAI API key from .env file
  String get openAIApiKey => _getEnvVariable('OPENAI_API_KEY');

  /// Zegocloud App ID from .env file
  int get zegoAppId {
    final value = _getEnvVariable('ZEGO_APP_ID');
    return int.parse(value);
  }

  /// Zegocloud App Sign from .env file
  String get zegoAppSign => _getEnvVariable('ZEGO_APP_SIGN');

  /// Initialize the environment configuration
  /// Should be called before any other methods
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load environment variables from .env file

      await dotenv.load(fileName: '.env');
      _initialized = true;
      debugPrint('Environment configuration loaded successfully');
    } catch (e) {
      debugPrint('Error loading environment variables: $e');
      debugPrint('Using fallback values for Stream Chat configuration');
      // We still mark as initialized, but will use fallback values
      _initialized = true;
    }
  }

  /// Get an environment variable with proper error handling
  String _getEnvVariable(String key) {
    if (!_initialized) {
      throw Exception('Environment configuration not initialized. Call initialize() first.');
    }

    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Environment variable $key not found or empty in .env file');
    }

    return value;
  }
}
