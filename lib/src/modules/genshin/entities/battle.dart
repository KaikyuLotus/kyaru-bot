import 'package:kyaru_bot/src/modules/genshin/entities/battle_avatar.dart';

class Battle {
  final int index;
  final String timestamp;
  final List<BattleAvatar> avatars;

  Battle({
    required this.index,
    required this.timestamp,
    required this.avatars,
  });

  static Battle fromJson(Map<String, dynamic> json) {
    return Battle(
      index: json['index'],
      timestamp: json['timestamp'],
      avatars: BattleAvatar.listFromJsonArray(json['avatars']),
    );
  }

  static List<Battle> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Battle.fromJson(json[index]));
  }
}
