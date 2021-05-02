import 'dart:convert';

import 'package:http/http.dart';

import 'anime.dart';

class KitsuApiException implements Exception {
  final String message;

  KitsuApiException(this.message);
}

class KitsuClient {
  final String apiBaseUrl = 'kitsu.io';

  final _client = Client();

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper) async {
    var response = await _client.get(uri).timeout(Duration(seconds: 120));
    if (response.statusCode != 200) {
      throw KitsuApiException(response.body);
    }
    var stringBody = response.body;
    return mapper(json.decode(stringBody));
  }

  Future<List<Anime>?> searchAnime(String query) async {
    return _get(
      Uri.https(apiBaseUrl, '/api/edge/anime', {
        'filter[text]': query,
      }),
      (d) => Anime.listFromJsonArray(d['data']),
    );
  }
}
