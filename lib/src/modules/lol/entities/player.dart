class Player {
  String platformId;
  String accountId;
  String summonerName;
  String summonerId;
  String currentPlatformId;
  String currentAccountId;
  String matchHistoryUri;
  int profileIcon;

  Player(
    this.platformId,
    this.accountId,
    this.summonerName,
    this.summonerId,
    this.currentPlatformId,
    this.currentAccountId,
    this.matchHistoryUri,
    this.profileIcon,
  );

  factory Player.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Player(
      json['platformId'],
      json['accountId'],
      json['summonerName'],
      json['summonerId'],
      json['currentPlatformId'],
      json['currentAccountId'],
      json['matchHistoryUri'],
      json['profileIcon'],
    );
  }

  static List<Player> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return null;
    return List.generate(jsonArray.length, (i) => Player.fromJson(jsonArray[i]));
  }
}
