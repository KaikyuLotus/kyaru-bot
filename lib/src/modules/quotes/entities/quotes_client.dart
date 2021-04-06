import 'dart:convert';

import 'package:http/http.dart';

import 'anime_quote.dart';

class QuotesClient {
  final String baseUrl = 'animechan.vercel.app';

  final _client = Client();

  Future<AnimeQuote> getRandomQuote() async {
    var response = await _client
        .get(Uri.https(baseUrl, '/api/random'))
        .timeout(Duration(seconds: 120));
    return AnimeQuote.fromJson(json.decode(response.body));
  }

  Future<Map> getQuote({
    required String mode,
    required Map<String, dynamic> parameters,
  }) async {
    var response = await _client
        .get(Uri.https(baseUrl, '/api/quotes/$mode', parameters))
        .timeout(Duration(seconds: 120));
    var result = json.decode(response.body);
    if (result is List) {
      result.shuffle();
      return result[0];
    }
    return result;
  }
}
