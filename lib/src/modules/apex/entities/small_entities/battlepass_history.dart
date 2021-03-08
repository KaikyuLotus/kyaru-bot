class BattlepassHistory {
  int? season1;
  int? season2;
  int? season3;
  int? season4;
  int? season5;

  BattlepassHistory(
    this.season1,
    this.season2,
    this.season3,
    this.season4,
    this.season5,
  );

  static BattlepassHistory fromJson(Map<String, dynamic> json) {
    return BattlepassHistory(
      json['season1'],
      json['season2'],
      json['season3'],
      json['season4'],
      json['season5'],
    );
  }
}
