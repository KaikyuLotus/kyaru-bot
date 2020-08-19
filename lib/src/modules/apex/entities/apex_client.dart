import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'apex_data.dart';

class ApexClient {
  final api_base_url = 'api.mozambiquehe.re';

  final _client = Client();

  final String _key;

  ApexClient(this._key);

  Future<Uint8List> downloadImage(String imageLink) async {
    var response = await _client.get(imageLink).timeout(Duration(seconds: 120));
    return response.bodyBytes;
  }

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper, [no_init = false]) async {
    var response = await _client.get(uri).timeout(Duration(seconds: 120));
    return mapper(json.decode(await response.body));
  }

  Future<ApexData> bridge(String player, {int version = 4, String platform = 'PC'}) async {
    return await _get(
      Uri.https(api_base_url, '/bridge', {'version': '$version', 'platform': platform, 'auth': _key, 'player': player}),
      (d) => ApexData.fromJson(d),
    );
  }
}
