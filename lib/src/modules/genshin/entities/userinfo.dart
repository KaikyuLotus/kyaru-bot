import 'package:kyaru_bot/src/modules/genshin/entities/world_exploration.dart';

import 'avatar.dart';
import 'city_exploration.dart';
import 'home.dart';
import 'stats.dart';

class UserInfo {
  final String? role;
  final List<Avatar> avatars;
  final Stats stats;
  final List<CityExploration> cityExplorations;
  final List<WorldExploration> worldExplorations;
  final List<Home> homes;

  WorldExploration get mondstadt => worldExplorationWithName('Mondstadt');
  WorldExploration get liyue => worldExplorationWithName('Liyue');
  WorldExploration get dragonspine => worldExplorationWithName('Dragonspine');
  WorldExploration get inazuma => worldExplorationWithName('Inazuma');

  UserInfo({
    required this.role,
    required this.avatars,
    required this.stats,
    required this.cityExplorations,
    required this.worldExplorations,
    required this.homes,
  });

  WorldExploration worldExplorationWithName(String name) {
    return worldExplorations.firstWhere((e) => e.name == name);
  }

  static UserInfo fromJson(Map<String, dynamic> json) {
    return UserInfo(
      role: json['role'],
      avatars: Avatar.listFromJsonArray(json['avatars']),
      stats: Stats.fromJson(json['stats']),
      cityExplorations: <CityExploration>[],
      // json['city_explorations']),
      worldExplorations: WorldExploration.listFromJsonArray(
        json['world_explorations'],
      ),
      homes: Home.listFromJsonArray(json['homes']),
    );
  }
}
