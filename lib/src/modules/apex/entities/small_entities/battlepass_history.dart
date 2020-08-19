class BattlepassHistory {

  BattlepassHistory(this.season1, this.season2, this.season3, this.season4, this.season5);

  factory BattlepassHistory.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return BattlepassHistory(
      json['season1'] as int,
      json['season2'] as int,
      json['season3'] as int,
      json['season4'] as int,
      json['season5'] as int,
    );
  }

  int season1;
  int season2;
  int season3;
  int season4;
  int season5;

}
