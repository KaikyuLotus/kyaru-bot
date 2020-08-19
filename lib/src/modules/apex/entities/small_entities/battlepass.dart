import 'battlepass_history.dart';

class Battlepass {
  Battlepass(this.level, this.history);

  factory Battlepass.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Battlepass(
      json['level'] as String,
      BattlepassHistory.fromJson(json['history'] as Map<String, dynamic>),
    );
  }

  String level;
  BattlepassHistory history;
}
