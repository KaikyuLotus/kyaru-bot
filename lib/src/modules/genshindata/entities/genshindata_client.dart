import 'dart:convert';

import 'package:http/http.dart';

import 'character.dart';

class GenshinDataException implements Exception {
  final String message;

  GenshinDataException(this.message);
}

class GenshinDataClient {
  final String _url;

  final _client = Client();

  GenshinDataClient(this._url);

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) mapper) async {
    var request = Request('GET', uri);
    var response = await _client.send(request).timeout(Duration(seconds: 120));
    var body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw GenshinDataException(body);
    }
    return mapper(json.decode(body));
  }

  Future<Character> getCharacter(String character, {int? level}) async {
    return _get(
      Uri.http(
        _url,
        '/character',
        {
          'character': character,
          'level': '$level',
        },
      ),
      Character.fromJson,
    );
  }
}
