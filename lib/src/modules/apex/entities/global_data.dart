import 'small_entities/bans.dart';
import 'small_entities/battlepass.dart';
import 'small_entities/rank.dart';

class GlobalData {

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

  factory GlobalData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return GlobalData(
      json['name'] as String,
      json['uid'] as int,
      json['platform'] as String,
      json['level'] as int,
      json['toNextLevelPercent'] as int,
      json['internalUpdateCount'] as int,
      Bans.fromJson(json['bans'] as Map<String, dynamic>),
      Rank.fromJson(json['rank'] as Map<String, dynamic>),
      Battlepass.fromJson(json['battlepass'] as Map<String, dynamic>),
    );
  }

  String name;
  int uid;
  String platform;
  int level;
  int toNextLevelPercent;
  int internalUpdateCount;

  Bans bans;
  Rank rank;
  Battlepass battlepass;

}
