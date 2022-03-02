import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'champion.dart';
import 'champion_mastery.dart';
import 'match_info.dart';
import 'summoner.dart';

class LOLClient {
  final _log = Logger('LOLClient');

  final String dataBaseUrl = 'ddragon.leagueoflegends.com';
  final String apiBaseUrl = 'euw1.api.riotgames.com';
  final String apiBaseUrl2 = 'europe.api.riotgames.com';

  final _client = Client();

  bool _initialized = false;

  bool get initialized => _initialized;

  String? key;
  String? version;

  late List<Champion> champions;

  LOLClient(this.key, [this.version]);

  Future _init() async {
    _log.info('Init LoL client...');
    version = version ?? await _getLatestVersion();
    champions = await _getChampions();

    _log.info('Loaded champions of version $version');
    _log.info('Loaded ${champions.length} champions');
    _initialized = true;
    _log.info('Done');
  }

  Future<T> _get<T>(
    Uri uri, {
    bool noInit = false,
    T Function(Map<String, dynamic>)? mapMapper,
    T Function(List<dynamic>)? listMapper,
  }) async {
    if (!_initialized && !noInit) {
      await _init();
    }
    var response = await _client.get(
      uri,
      headers: {'X-Riot-Token': key!},
    ).timeout(
      Duration(seconds: 120),
    );

    var decoded = json.decode(response.body);
    if (mapMapper != null) return mapMapper(decoded);
    return listMapper!.call(decoded);
  }

  Future<String> _getLatestVersion() async => (await _getVersions()).first;

  Future<List<String>> _getVersions() async {
    return _get(
      Uri.https(dataBaseUrl, '/api/versions.json'),
      listMapper: (d) => List.from(d),
      noInit: true,
    );
  }

  Future<List<Champion>> _getChampions() async {
    return _get(
      Uri.https(dataBaseUrl, '/cdn/$version/data/en_US/champion.json'),
      mapMapper: Champion.listFromResponse,
      noInit: true,
    );
  }

  Champion? findChampionById(String champId) {
    var matches = champions.where((c) => c.key == champId);
    if (matches.isEmpty) return null;
    return matches.first;
  }

  Future<List<ChampionMastery>> getChampionsMasteryBySummonerId(
    String? summonerId,
  ) async {
    return _get(
      Uri.https(
        apiBaseUrl,
        '/lol/champion-mastery/v4/champion-masteries/by-summoner/$summonerId',
      ),
      listMapper: ChampionMastery.listFromJsonArray,
    );
  }

  Future<Summoner?> getSummoner(String name) async {
    return _get(
      Uri.https(apiBaseUrl, '/lol/summoner/v4/summoners/by-name/$name'),
      mapMapper: (d) {
        if ((d['status']?['status_code'] ?? 200) == 404) return null;
        return Summoner.fromJson(d);
      },
    );
  }

  Future<List<String>> getMatches(String? summonerAccount) async {
    return _get(
      Uri.https(
        apiBaseUrl2,
        '/lol/match/v5/matches/by-puuid/$summonerAccount/ids',
      ),
      listMapper: (d) => List.from(d),
    );
  }

  Future<MatchInfo> getMatch(String matchId) async {
    return _get(
      Uri.https(
        apiBaseUrl2,
        '/lol/match/v5/matches/$matchId',
      ),
      mapMapper: MatchInfo.fromJson,
    );
  }
}
