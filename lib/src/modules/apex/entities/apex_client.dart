import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'apex_data.dart';

class ApexClient {
  final String apiBaseUrl = 'api.mozambiquehe.re';
  final Client _client = Client();
  final String? _key;

  ApexClient(this._key);

  Future<Uint8List> downloadImage(String imageLink) async {
    final response = await _client
        .get(Uri.parse(imageLink))
        .timeout(const Duration(seconds: 120));
    return response.bodyBytes;
  }

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) mapper) async {
    final response = await _client.get(uri).timeout(
          const Duration(seconds: 120),
        );
    return mapper(json.decode(response.body));
  }

  Future<ApexData> bridge(
    String player, {
    int version = 4,
    String platform = 'PC',
  }) async {
    return _get(
      Uri.https(apiBaseUrl, '/bridge', <String, String?>{
        'version': '$version',
        'platform': platform,
        'auth': _key,
        'player': player,
      }),
      ApexData.fromJson,
    );
  }
}
