class ParticipantStats {
  int? participantId;
  bool? win;
  int? kills;
  int? deaths;
  int? assists;

  ParticipantStats(
    this.participantId,
    this.kills,
    this.deaths,
    this.assists, {
    this.win,
  });

  static ParticipantStats fromJson(dynamic json) {
    return ParticipantStats(
      json['participantId'],
      json['kills'],
      json['deaths'],
      json['assists'],
      win: json['win'],
    );
  }
}
