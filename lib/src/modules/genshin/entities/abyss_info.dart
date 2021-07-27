import 'rank.dart';

import 'floor.dart';

class AbyssInfo {
  final int scheduleId;
  final String startTime;
  final String endTime;
  final int totalBattleTimes;
  final int totalWinTimes;
  final String maxFloor;
  final List<Rank> revealRank;
  final List<Rank> defeatRank;
  final List<Rank> damageRank;
  final List<Rank> takeDamageRank;
  final List<Rank> normalSkillRank;
  final List<Rank> energySkillRank;
  final List<Floor> floors;
  final int totalStar;
  final bool isUnlock;

  AbyssInfo({
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.totalBattleTimes,
    required this.totalWinTimes,
    required this.maxFloor,
    required this.revealRank,
    required this.defeatRank,
    required this.damageRank,
    required this.takeDamageRank,
    required this.normalSkillRank,
    required this.energySkillRank,
    required this.floors,
    required this.totalStar,
    required this.isUnlock,
  });

  static AbyssInfo fromJson(Map<String, dynamic> json) {
    return AbyssInfo(
      scheduleId: json['schedule_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalBattleTimes: json['total_battle_times'],
      totalWinTimes: json['total_win_times'],
      maxFloor: json['max_floor'],
      revealRank: Rank.listFromJsonArray(json['reveal_rank']),
      defeatRank: Rank.listFromJsonArray(json['defeat_rank']),
      damageRank: Rank.listFromJsonArray(json['damage_rank']),
      takeDamageRank: Rank.listFromJsonArray(json['take_damage_rank']),
      normalSkillRank: Rank.listFromJsonArray(json['normal_skill_rank']),
      energySkillRank: Rank.listFromJsonArray(json['energy_skill_rank']),
      floors: Floor.listFromJsonArray(json['floors']),
      totalStar: json['total_star'],
      isUnlock: json['is_unlock'],
    );
  }
}
