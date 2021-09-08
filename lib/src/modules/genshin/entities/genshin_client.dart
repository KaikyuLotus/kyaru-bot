import 'dart:convert';

import 'package:http/http.dart';
import 'package:kyaru_bot/src/modules/genshin/entities/user_characters.dart';

class GenshinApiException implements Exception {
  final String message;

  GenshinApiException(this.message);

  @override
  String toString() {
    return 'GenshinApiException: $message';
  }
}

class GenshinClient {
  final String baseUrl;

  final _client = Client();

  GenshinClient(this.baseUrl);

  Future<Map<String, dynamic>> getUser(int uid) async {
    var response = await _client
        .get(Uri.http(baseUrl, '/user', {'game_id': '$uid'}))
        .timeout(Duration(seconds: 120));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAbyss(int uid) async {
    var response = await _client
        .get(Uri.http(baseUrl, '/abyss', {'game_id': '$uid'}))
        .timeout(Duration(seconds: 120));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getApiStats() async {
    var response = await _client
        .get(Uri.http(baseUrl, '/stats'))
        .timeout(Duration(seconds: 120));
    return jsonDecode(response.body);
  }

  Future<UserCharacters> getCharacters(int uid, List<int> characterIds) async {
    var response = await _client
        .get(Uri.http(baseUrl, '/character', {
          'game_id': '$uid',
          'ids': json.encode(characterIds),
        }))
        .timeout(Duration(seconds: 120));

    var baseResponse = jsonDecode(response.body);
    var ok = baseResponse['ok'] as bool;
    if (!ok) {
      throw GenshinApiException(baseResponse['error']);
    }
    // oldData is not used yet
    var hoyolabData = baseResponse['data']['data'];
    if (hoyolabData['retcode'] != 0) {
      throw GenshinApiException(hoyolabData['message']);
    }

    return UserCharacters.fromJson(hoyolabData['data']);
  }

  void close() {
    _client.close();
  }
}
