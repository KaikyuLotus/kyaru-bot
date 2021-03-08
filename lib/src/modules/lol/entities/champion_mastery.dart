class ChampionMastery {
  int? championId;
  int? championLevel;
  int? championPoints;
  int? lastPlayTime;
  int? championPointsSinceLastLevel;
  int? championPointsUntilNextLevel;
  bool? chestGranted;
  int? tokensEarned;
  String? summonerId;

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

  static ChampionMastery fromJson(dynamic json) {
    return ChampionMastery(
      json['championId'],
      json['championLevel'],
      json['championPoints'],
      json['lastPlayTime'],
      json['championPointsSinceLastLevel'],
      json['championPointsUntilNextLevel'],
      json['tokensEarned'],
      json['summonerId'],
      chestGranted: json['chestGranted'],
    );
  }

  static List<ChampionMastery> listFromJsonArray(dynamic jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => ChampionMastery.fromJson(jsonArray[i]),
    );
  }
}
