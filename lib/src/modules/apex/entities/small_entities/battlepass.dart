import 'battlepass_history.dart';

class Battlepass {
  String? level;
  BattlepassHistory history;

  Battlepass(this.level, this.history);

  static Battlepass fromJson(Map<String, dynamic> json) {
    return Battlepass(
      json['level'],
      BattlepassHistory.fromJson(json['history']),
    );
  }
}
