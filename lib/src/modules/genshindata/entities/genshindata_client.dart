import 'dart:convert';

import 'package:http/http.dart';

import 'artifact_set.dart';
import 'character.dart';
import 'constellations.dart';
import 'talent.dart';
import 'weapon.dart';

class GenshinDataException implements Exception {
  final String message;

  GenshinDataException(this.message);

  @override
  String toString() => 'GenshinDataException: $message';
}

class GenshinDataClient {
  final String _url;

  final _client = Client();

  GenshinDataClient(this._url);

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) mapper) async {
    var request = Request('GET', uri);
    var response = await _client.send(request).timeout(Duration(seconds: 120));
    var body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw GenshinDataException(body);
    }
    return mapper(json.decode(body));
  }

  Future<Character> getCharacter(String character, {int? level}) async {
    return _get(
      Uri.http(
        _url,
        '/character',
        {
          'character': character,
          'level': '$level',
        },
      ),
      Character.fromJson,
    );
  }

  Future<Constellations> getConstellations(String character) async {
    return _get(
      Uri.http(
        _url,
        '/constellations',
        {
          'character': character,
        },
      ),
      Constellations.fromJson,
    );
  }

  Future<Weapon> getWeapon(String weapon) async {
    return _get(
      Uri.http(
        _url,
        '/weapon',
        {
          'weapon': weapon,
        },
      ),
      Weapon.fromJson,
    );
  }

  Future<List<Talent>> getTalents(String character) async {
    return _get(
      Uri.http(
        _url,
        '/talents',
        {
          'character': character,
        },
      ),
      Talent.listFromJsonArray,
    );
  }

  Future<ArtifactSet> getArtifactSet(String artifact) async {
    return _get(
      Uri.http(
        _url,
        '/artifact',
        {
          'artifact': artifact,
        },
      ),
      ArtifactSet.fromJson,
    );
  }
}
