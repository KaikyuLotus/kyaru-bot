import 'dart:convert';

import 'package:http/http.dart';

import 'champion.dart';
import 'champion_mastery.dart';
import 'match.dart';
import 'match_info.dart';
import 'summoner.dart';

class LOLClient {
  final String dataBaseUrl = 'ddragon.leagueoflegends.com';
  final String apiBaseUrl = 'euw1.api.riotgames.com';

  final _client = Client();

  bool _inited = false;

  bool get inited => _inited;

  String key;
  String version;

  List<Champion> champions;

  LOLClient(this.key, [this.version]);

  Future _init() async {
    print('Initing LoL client...');
    version = version ?? await _getLatestVersion();
    champions = await _getChampions();

    print('Loaded champions of version $version');
    print('Loaded ${champions.length} champions');
    _inited = true;
    print('Done');
  }

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper, [bool noInit = false]) async {
    if (!_inited && !noInit) {
      await _init();
    }
    var response = await _client.get(uri, headers: {'X-Riot-Token': key}).timeout(Duration(seconds: 120));
    return mapper(json.decode(response.body));
  }

  Future<String> _getLatestVersion() async {
    return (await _getVersions()).first;
  }

  Future<List<String>> _getVersions() async {
    return await _get(Uri.https(dataBaseUrl, '/api/versions.json'), (d) => List.from(d), true);
  }

  Future<List<Champion>> _getChampions() async {
    return await _get(
      Uri.https(dataBaseUrl, '/cdn/$version/data/en_US/champion.json'),
      Champion.listFromResponse,
      true,
    );
  }

  Champion findChampionById(String champId) => champions.firstWhere((c) => c.key == champId);

  Future<List<ChampionMastery>> getChampionsMasteryBySummonerId(String summonerId) async {
    return await _get(
      Uri.https(apiBaseUrl, '/lol/champion-mastery/v4/champion-masteries/by-summoner/$summonerId'),
      ChampionMastery.listFromJsonArray,
    );
  }

  Future<Summoner> getSummoner(String name) async {
    return await _get(
      Uri.https(apiBaseUrl, '/lol/summoner/v4/summoners/by-name/$name'),
      (d) => Summoner.fromJson(d),
    );
  }

  Future<List<Match>> getMatches(String summonerAccount) async {
    return await _get(
      Uri.https(apiBaseUrl, '/lol/match/v4/matchlists/by-account/$summonerAccount'),
      (d) => Match.listFromJsonArray(d['matches']),
    );
  }

  Future<MatchInfo> getMatch(int matchId) async {
    return await _get(
      Uri.https(apiBaseUrl, '/lol/match/v4/matches/$matchId'),
      (d) => MatchInfo.fromJson(d),
    );
  }
}
