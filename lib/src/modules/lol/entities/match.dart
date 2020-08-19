class Match {
  String platformId;
  int gameId;
  int champion;
  int queue;
  int season;
  int timestamp;
  String role;
  String lane;

  Match(this.platformId, this.gameId, this.champion, this.queue, this.season, this.timestamp, this.role, this.lane);

  factory Match.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
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
    if (jsonArray == null) return null;
    return List.generate(jsonArray.length, (i) => Match.fromJson(jsonArray[i]));
  }
}
