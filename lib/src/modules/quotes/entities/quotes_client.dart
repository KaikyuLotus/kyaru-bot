import 'dart:convert';

import 'package:http/http.dart';

import 'anime_quote.dart';

class QuotesClient {
  final String baseUrl = 'animechan.vercel.app';

  final _client = Client();

  Future<AnimeQuote> getQuote() async {
    var response = await _client
        .get(Uri.https(baseUrl, '/api/random'))
        .timeout(Duration(seconds: 120));
    return AnimeQuote.fromJson(json.decode(response.body));
  }
}
