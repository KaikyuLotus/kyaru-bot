import 'dart:convert';

import 'package:http/http.dart';

class GenshinClient {
  final String baseUrl;

  final _client = Client();

  GenshinClient(this.baseUrl);

  Future<Map<String, dynamic>> getUser(int? id) async {
    var response = await _client
        .get(Uri.http(baseUrl, '/user/$id'))
        .timeout(Duration(seconds: 120));
    var cacheTime = int.parse(response.headers['cache'] ?? 0 as String) ~/ 1000;
    return {'data': jsonDecode(response.body), 'cache': cacheTime};
  }
}
