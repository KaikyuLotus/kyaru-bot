import 'small_entities/bans.dart';
import 'small_entities/battlepass.dart';
import 'small_entities/rank.dart';

class GlobalData {

  String name;
  int uid;
  String? platform;
  int level;
  int toNextLevelPercent;
  int? internalUpdateCount;

  Bans bans;
  Rank rank;
  Battlepass battlepass;

  GlobalData(
    this.name,
    this.uid,
    this.platform,
    this.level,
    this.toNextLevelPercent,
    this.internalUpdateCount,
    this.bans,
    this.rank,
    this.battlepass,
  );

  static GlobalData fromJson(Map<String, dynamic> json) {
    return GlobalData(
      json['name'],
      json['uid'],
      json['platform'],
      json['level'],
      json['toNextLevelPercent'],
      json['internalUpdateCount'],
      Bans.fromJson(json['bans']),
      Rank.fromJson(json['rank']),
      Battlepass.fromJson(json['battlepass']),
    );
  }
}
