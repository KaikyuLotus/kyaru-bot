class ParticipantStats {
  int participantId;
  bool win;
  int kills;
  int deaths;
  int assists;

  ParticipantStats(this.participantId, this.win, this.kills, this.deaths, this.assists);

  factory ParticipantStats.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ParticipantStats(
      json['participantId'],
      json['win'],
      json['kills'],
      json['deaths'],
      json['assists'],
    );
  }
}
