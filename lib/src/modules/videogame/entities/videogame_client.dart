import 'dart:convert';

import 'package:http/http.dart';

import 'platform.dart';
import 'videogame.dart';
import 'videogame_details.dart';

class VideogameException implements Exception {
  final String message;

  VideogameException(this.message);

  @override
  String toString() => 'VideogameException: $message';
}

class VideogameClient {
  final String baseUrl = 'api.rawg.io';
  final String? _key;

  final _client = Client();

  VideogameClient(this._key);

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) mapper) async {
    var request = Request('GET', uri);
    var response = await _client.send(request).timeout(Duration(seconds: 120));
    var body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw VideogameException(body);
    }
    return mapper(json.decode(body));
  }

  Future<Videogame> getVideogame(String title) async {
    return _get(
      Uri.https(
        baseUrl,
        '/api/games',
        {
          'key': _key,
          'search': title,
        },
      ),
      (d) => Videogame.fromJson(d['results'][0]),
    );
  }

  Future<VideogameDetails> getVideogameDetails(String title) async {
    var videogame = await getVideogame(title);
    return _get(
      Uri.https(
        baseUrl,
        '/api/games/${videogame.id}',
        {
          'key': _key,
        },
      ),
      VideogameDetails.fromJson,
    );
  }

  Future<List<Platform>> getPlatformList() async {
    return _get(
      Uri.https(
        baseUrl,
        '/api/platforms',
        {
          'key': _key,
        },
      ),
      (d) => Platform.listFromJsonArray(d['results']),
    );
  }
}
