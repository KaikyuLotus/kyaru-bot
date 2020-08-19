import 'dart:convert';

import 'package:http/http.dart';

import 'anime.dart';

class JikanClient {
  final api_base_url = 'api.jikan.moe';

  final _client = Client();

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper, [no_init = false]) async {
    print(uri.toString());
    var response = await _client.get(uri).timeout(Duration(seconds: 120));
    var stringBody = await response.body;
    print(stringBody);
    return mapper(json.decode(stringBody));
  }

  Future<List<Anime>> search(String searchString, {int limit = 1, String type = 'anime'}) async {
    return await _get(
      Uri.https(api_base_url, '/v3/search/anime', {'q': searchString, 'limit': '$limit', 'type': type}),
      (d) => Anime.listFromJsonArray(d['results']),
    );
  }
}
