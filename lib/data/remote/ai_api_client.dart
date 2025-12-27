import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart';
import 'package:adda_time/core/config/env_config.dart';

class AiApiClient {
  final _base = 'https://api.openai.com/v1';
  http.Client? _client;

  http.Client get client {
    if (_client == null) {
      // In debug mode, create a client that accepts all certificates (for emulator testing)
      if (kDebugMode) {
        final httpClient = HttpClient()
          ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        _client = IOClient(httpClient);
      } else {
        _client = http.Client();
      }
    }
    return _client!;
  }

  Future<String> sendMessage(String prompt) async {
    try {
      final apiKey = EnvConfig.instance.openAIApiKey;
      final url = Uri.parse('$_base/chat/completions');

      final body = json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 512,
        'temperature': 0.8,
      });

      final resp = await client
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final j = json.decode(resp.body) as Map<String, dynamic>;
        final choices = j['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content'] as String? ?? '';
        }
        return '';
      } else {
        throw Exception('OpenAI API error: ${resp.statusCode} - ${resp.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Network error: Unable to connect to OpenAI. Please check your internet connection. ${e.message}');
    } on HandshakeException catch (e) {
      throw Exception('SSL/TLS error: Unable to establish secure connection to OpenAI. This may be an emulator issue. Try on a physical device. ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  void dispose() {
    _client?.close();
  }
}
