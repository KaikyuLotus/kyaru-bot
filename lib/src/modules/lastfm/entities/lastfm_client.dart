import 'dart:convert';

import 'package:http/http.dart';

import 'recent_track.dart';

class LastfmException implements Exception {
  final String message;

  LastfmException(this.message);
}

class LastfmClient {
  final String baseUrl = 'ws.audioscrobbler.com';
  final String? _key;

  LastfmClient(this._key);

  final _client = Client();

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) mapper) async {
    var request = Request('GET', uri);
    var response = await _client.send(request).timeout(Duration(seconds: 120));
    var body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw LastfmException(body);
    }
    return mapper(json.decode(body));
  }

  Future<RecentTrack> getLastTrack(String user) {
    return _get(
      Uri.https(
        baseUrl,
        '/2.0/',
        {
          'api_key': _key,
          'method': 'user.getrecenttracks',
          'user': user,
          'format': 'json',
          'limit': '1',
        },
      ),
      (d) => RecentTrack.fromJson(d['recenttracks']['track'][0]),
    );
  }
}
