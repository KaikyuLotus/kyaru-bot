import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import '../entities/genshin_entities.dart';

class RendererException implements Exception {
  String message;
  int statusCode;

  RendererException({required this.message, required this.statusCode});

  @override
  String toString() => 'RendererException: $message - status: $statusCode';
}

extension on Response {
  void raiseForStatus() {
    if (statusCode != 200) {
      throw RendererException(message: body, statusCode: statusCode);
    }
  }
}

class RendererClient {
  String baseUrl;

  final _timeout = const Duration(seconds: 30);

  final _client = Client();

  RendererClient(this.baseUrl);

  Future<Uint8List> getCharacter(
    DetailedAvatar avatar, {
    double pixelRatio = 1.0,
    double windowMultiplier = 70.0,
  }) async {
    var response = await _client
        .post(
          Uri.http(baseUrl, '/genshin_character'),
          body: json.encode(
            {
              'window_multiplier': windowMultiplier,
              'pixel_ratio': pixelRatio,
              'avatar': avatar,
            },
          ),
        )
        .timeout(_timeout);
    response.raiseForStatus();
    return response.bodyBytes;
  }

  Future<Uint8List> getCharacters(
    UserInfo userInfo, {
    double pixelRatio = 1.0,
    double windowMultiplier = 180,
  }) async {
    var response = await _client
        .post(
          Uri.http(baseUrl, '/genshin_characters'),
          body: json.encode(
            {
              'window_multiplier': windowMultiplier,
              'pixel_ratio': pixelRatio,
              'user_info': userInfo,
            },
          ),
        )
        .timeout(_timeout);
    response.raiseForStatus();
    return response.bodyBytes;
  }

  Future<Uint8List> health() async {
    var response = await _client
        .post(Uri.http(baseUrl, '/health'), body: '{}')
        .timeout(Duration(seconds: 3));
    response.raiseForStatus();
    return response.bodyBytes;
  }
}
