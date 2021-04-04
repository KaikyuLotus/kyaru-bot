import 'dart:convert';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:http/http.dart';

import 'anime.dart';
import 'character.dart';

class JikanApiException implements Exception {

  final String message;

  JikanApiException(this.message);

}

class JikanClient {
  final String apiBaseUrl = 'api.jikan.moe';

  final _client = Client();

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper) async {
    var response = await _client.get(uri).timeout(Duration(seconds: 120));
    if (response.statusCode != 200) {
      throw JikanApiException(response.body);
    }
    var stringBody = response.body;
    return mapper(json.decode(stringBody));
  }

  Future<List<Anime>?> searchAnime(
    String searchString, {
    int limit = 1,
  }) async {
    return _get(
      Uri.https(apiBaseUrl, '/v3/search/anime', {
        'q': searchString,
        'limit': '$limit',
      }),
      (d) => Anime.listFromJsonArray(d['results']),
    );
  }

  Future<List<Character>?> searchCharacter(
    String searchString, {
    int limit = 1,
  }) async {
    return _get(
      Uri.https(apiBaseUrl, '/v3/search/character', {
        'q': searchString,
        'limit': '$limit',
      }),
      (d) => Character.listFromJsonArray(d['results']),
    );
  }
}
