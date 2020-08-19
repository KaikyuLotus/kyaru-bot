import 'dart:convert';

import 'package:http/http.dart';

import 'champion.dart';
import 'champion_mastery.dart';
import 'match.dart';
import 'match_info.dart';
import 'summoner.dart';

class LOLClient {
  final data_base_url = 'ddragon.leagueoflegends.com';
  final api_base_url = 'euw1.api.riotgames.com';

  final _client = Client();

  bool _inited = false;

  bool get inited => _inited;

  String key;
  String version;

  List<Champion> champions;

  LOLClient(this.key, [this.version]);

  Future _init() async {
    print('Initing LoL client...');
    version = version ?? await _get_latest_version();
    champions = await _get_champions();

    print('Loaded champions of version ${version}');
    print('Loaded ${champions.length} champions');
    _inited = true;
    print('Done');
  }

  Future<T> _get<T>(Uri uri, T Function(dynamic) mapper, [no_init = false]) async {
    if (!_inited && !no_init) await _init();
    var response = await _client.get(uri, headers: {'X-Riot-Token': key}).timeout(Duration(seconds: 120));
    return mapper(json.decode(await response.body));
  }

  Future<String> _get_latest_version() async {
    return (await _get_versions()).first;
  }

  Future<List<String>> _get_versions() async {
    return await _get(Uri.https(data_base_url, '/api/versions.json'), (d) => List.from(d), true);
  }

  Future<List<Champion>> _get_champions() async {
    return await _get(
      Uri.https(data_base_url, '/cdn/${version}/data/en_US/champion.json'),
      (d) => Champion.listFromResponse(d),
      true,
    );
  }

  Champion findChampionById(String champ_id) => champions.firstWhere((c) => c.key == champ_id);

  Future<List<ChampionMastery>> getChampionsMasteryBySummonerId(String summonerId) async {
    return await _get(
      Uri.https(api_base_url, '/lol/champion-mastery/v4/champion-masteries/by-summoner/${summonerId}'),
      (d) => ChampionMastery.listFromJsonArray(d),
    );
  }

  Future<Summoner> getSummoner(String name) async {
    return await _get(
      Uri.https(api_base_url, '/lol/summoner/v4/summoners/by-name/${name}'),
      (d) => Summoner.fromJson(d),
    );
  }

  Future<List<Match>> getMatches(String summonerAccount) async {
    return await _get(
      Uri.https(api_base_url, '/lol/match/v4/matchlists/by-account/${summonerAccount}'),
      (d) => Match.listFromJsonArray(d['matches']),
    );
  }

  Future<MatchInfo> getMatch(int matchId) async {
    return await _get(
      Uri.https(api_base_url, '/lol/match/v4/matches/${matchId}'),
      (d) => MatchInfo.fromJson(d),
    );
  }
}
