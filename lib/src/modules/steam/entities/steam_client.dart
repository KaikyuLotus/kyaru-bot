import 'dart:convert';

import 'package:http/http.dart';

import 'user.dart';

class SteamException implements Exception {
  final String message;

  SteamException(this.message);
}

class SteamClient {
  final String baseUrl = 'api.steampowered.com';
  final String? _key;

  final _client = Client();

  SteamClient(this._key);

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) mapper) async {
    var request = Request('GET', uri);
    var response = await _client.send(request).timeout(Duration(seconds: 120));
    var body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw SteamException(body);
    }
    return mapper(json.decode(body)['response']);
  }

  Future<String> idFromUser(String user) async {
    return _get(
      Uri.https(
        baseUrl,
        '/ISteamUser/ResolveVanityURL/v0001/',
        {
          'key': _key,
          'vanityurl': user,
        },
      ),
      (d) => d['steamid'],
    );
  }

  Future<User> getUser(String user) async {
    var steamId = await idFromUser(user);
    return _get(
      Uri.https(
        baseUrl,
        '/ISteamUser/GetPlayerSummaries/v0002/',
        {
          'key': _key,
          'steamids': steamId,
        },
      ),
      (d) => User.fromJson(d['players'][0]),
    );
  }
}
