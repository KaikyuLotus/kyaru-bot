import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import '../entities/honkai_entities.dart';

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

  Future<Uint8List> getCharacters(UserCharacters characters) async {
    var response = await _client
        .post(
          Uri.http(baseUrl, '/honkai_characters'),
          body: json.encode(
            {
              'data': characters,
            },
          ),
        )
        .timeout(_timeout);
    response.raiseForStatus();
    return response.bodyBytes;
  }

  Future<Uint8List> getCharacter(Character character) async {
    var response = await _client
        .post(
          Uri.http(baseUrl, '/honkai_character'),
          body: json.encode(
            {
              'data': character,
            },
          ),
        )
        .timeout(_timeout);
    response.raiseForStatus();
    return response.bodyBytes;
  }
}
