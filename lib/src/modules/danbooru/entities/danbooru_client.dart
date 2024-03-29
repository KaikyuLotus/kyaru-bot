import 'dart:convert';

import 'package:http/http.dart';

import 'post.dart';

class DanbooruException implements Exception {
  final String message;

  DanbooruException(this.message);

  @override
  String toString() => 'DanbooruException: $message';
}

class DanbooruClient {
  final String baseUrl = 'danbooru.donmai.us';

  final _client = Client();

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper) async {
    var response = await _client.get(uri).timeout(Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw DanbooruException(response.body);
    }
    return mapper(json.decode(response.body));
  }

  Future<List<Post>> getPosts({
    List<String>? tags,
    int limit = 100,
    bool random = true,
  }) async {
    return _get(
      Uri.https(
        baseUrl,
        '/posts.json',
        {
          'tags': (tags ?? []).join(' '),
          'limit': '$limit',
          'random': '$random',
        },
      ),
      Post.listFromJsonArray,
    );
  }
}
