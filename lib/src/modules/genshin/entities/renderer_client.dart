import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'user_characters.dart';

class RendererClient {
  final String baseUrl;

  final _client = Client();

  RendererClient(this.baseUrl);

  Future<Uint8List> getCharacter(UserCharacters userCharacters) async {
    var response = await _client
        .post(
          Uri.http(baseUrl, '/test'),
          body: json.encode(
            {
              'data': {
                'data': {
                  'data': userCharacters.toJson(),
                }
              }
            },
          ),
        )
        .timeout(Duration(seconds: 120));
    return response.bodyBytes;
  }
}
