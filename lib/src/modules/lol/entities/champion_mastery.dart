class ChampionMastery {
  int championId;
  int championLevel;
  int championPoints;
  int lastPlayTime;
  int championPointsSinceLastLevel;
  int championPointsUntilNextLevel;
  bool chestGranted;
  int tokensEarned;
  String summonerId;

  ChampionMastery(
      this.championId,
      this.championLevel,
      this.championPoints,
      this.lastPlayTime,
      this.championPointsSinceLastLevel,
      this.championPointsUntilNextLevel,
      this.chestGranted,
      this.tokensEarned,
      this.summonerId);

  factory ChampionMastery.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ChampionMastery(
      json['championId'],
      json['championLevel'],
      json['championPoints'],
      json['lastPlayTime'],
      json['championPointsSinceLastLevel'],
      json['championPointsUntilNextLevel'],
      json['chestGranted'],
      json['tokensEarned'],
      json['summonerId'],
    );
  }

  static List<ChampionMastery> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return null;
    return List.generate(jsonArray.length, (i) => ChampionMastery.fromJson(jsonArray[i]));
  }
}
