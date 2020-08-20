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
    this.tokensEarned,
    this.summonerId, {
    this.chestGranted,
  });

  factory ChampionMastery.fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return ChampionMastery(
        json['championId'],
        json['championLevel'],
        json['championPoints'],
        json['lastPlayTime'],
        json['championPointsSinceLastLevel'],
        json['championPointsUntilNextLevel'],
        json['tokensEarned'],
        json['summonerId'],
        chestGranted: json['chestGranted']);
  }

  static List<ChampionMastery> listFromJsonArray(dynamic jsonArray) {
    if (jsonArray == null) {
      return null;
    }
    return List.generate(jsonArray.length, (i) => ChampionMastery.fromJson(jsonArray[i]));
  }
}
