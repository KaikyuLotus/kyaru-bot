class Match {
  String? platformId;
  int gameId;
  int? champion;
  int? queue;
  int? season;
  int? timestamp;
  String? role;
  String? lane;

  Match(
    this.platformId,
    this.gameId,
    this.champion,
    this.queue,
    this.season,
    this.timestamp,
    this.role,
    this.lane,
  );

  static Match fromJson(Map<String, dynamic> json) {
    return Match(
      json['platformId'],
      json['gameId'],
      json['champion'],
      json['queue'],
      json['season'],
      json['timestamp'],
      json['role'],
      json['lane'],
    );
  }

  static List<Match> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Match.fromJson(jsonArray[i]),
    );
  }
}
