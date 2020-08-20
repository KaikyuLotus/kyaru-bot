import 'battlepass_history.dart';

class Battlepass {
  String level;
  BattlepassHistory history;

  Battlepass(this.level, this.history);

  factory Battlepass.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Battlepass(
      json['level'],
      BattlepassHistory.fromJson(json['history']),
    );
  }
}
