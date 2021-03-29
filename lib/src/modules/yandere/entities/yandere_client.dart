import 'dart:convert';

import 'package:http/http.dart';

import 'post.dart';

class YandereClient {
  final String baseUrl = 'yande.re';

  final Client _client = Client();

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper) async {
    final response = await _client.get(uri).timeout(
          const Duration(seconds: 120),
        );
    if (response.statusCode != 200) {
      throw Exception(response.body); // TODO specialize
    }
    return mapper(json.decode(response.body));
  }

  Future<List<Post>?> getPosts({
    List<String>? tags,
    int limit = 100,
    bool random = true,
  }) {
    return _get(
      Uri.https(
        baseUrl,
        '/post.json',
        <String, String>{
          'tags': (tags ?? <String>[]).join(' '),
          'limit': '$limit',
          'random': '$random',
        },
      ),
      Post.listFromJsonArray,
    );
  }
}
