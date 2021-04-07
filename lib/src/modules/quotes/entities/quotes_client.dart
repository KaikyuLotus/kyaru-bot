import 'dart:convert';

import 'package:http/http.dart';

import 'anime_quote.dart';

class NotFound implements Exception {
  final String message;

  NotFound(this.message);
}

class QuotesClient {
  final String baseUrl = 'animechan.vercel.app';

  final _client = Client();

  Future<dynamic> _get(Uri uri) async {
    var response = await _client.get(uri).timeout(Duration(seconds: 120));
    if (response.statusCode != 200) {
      throw NotFound(response.body);
    }
    return json.decode(response.body);
  }

  Future<AnimeQuote> getRandomQuote() async {
    var quote = await _get(
      Uri.https(
        baseUrl,
        '/api/random',
      ),
    );
    return AnimeQuote.fromJson(quote);
  }

  Future<List<AnimeQuote>> getQuotes({
    required String mode,
    required Map<String, dynamic> parameters,
  }) async {
    List quotes = await _get(
      Uri.https(
        baseUrl,
        '/api/quotes/$mode',
        parameters,
      ),
    );
    return AnimeQuote.listFromJsonArray(quotes);
  }
}
