class Participant {
  int? participantId;
  String summonerId;
  int? teamId;
  int? championId;
  bool win;
  int kills;
  int deaths;
  int assists;

  Participant(
    this.participantId,
    this.summonerId,
    this.teamId,
    this.championId,
    this.win,
    this.kills,
    this.deaths,
    this.assists,
  );

  static Participant fromJson(Map<String, dynamic> json) {
    return Participant(
      json['participantId'],
      json['summonerId'],
      json['teamId'],
      json['championId'],
      json['win'],
      json['kills'],
      json['deaths'],
      json['assists'],
    );
  }

  static List<Participant> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Participant.fromJson(jsonArray[i]),
    );
  }
}
