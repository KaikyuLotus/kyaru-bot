import 'dart:convert';

import 'package:http/http.dart';

class GenshinClient {
  final String baseUrl;

  final _client = Client();

  GenshinClient(this.baseUrl);

  Future<Map<String, dynamic>> getUser(int uid) async {
    var response = await _client
        .get(Uri.http(baseUrl, '/user', {'uid': '$uid'}))
        .timeout(Duration(seconds: 120));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAbyss(int uid) async {
    var response = await _client
        .get(Uri.http(baseUrl, '/abyss', {'uid': '$uid'}))
        .timeout(Duration(seconds: 120));
    return jsonDecode(response.body);
  }

}
