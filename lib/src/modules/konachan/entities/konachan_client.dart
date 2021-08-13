import 'dart:convert';

import 'package:http/http.dart';

import 'post.dart';

class KonachanException implements Exception {
  final String message;

  KonachanException(this.message);

  @override
  String toString() => 'KonachanException: $message';
}

class KonachanClient {
  final String baseUrl = 'konachan.com';

  final Client _client = Client();

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper) async {
    final response = await _client.get(uri).timeout(Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw KonachanException(response.body);
    }
    return mapper(json.decode(response.body));
  }

  Future<List<Post>> getPosts({
    List<String> tags = const <String>[],
    int limit = 100,
    bool random = true,
  }) {
    return _get(
      Uri.https(
        baseUrl,
        '/post.json',
        {
          'tags': tags.join(' '),
          'limit': '$limit',
          'random': '$random',
        },
      ),
      Post.listFromJsonArray,
    );
  }
}
