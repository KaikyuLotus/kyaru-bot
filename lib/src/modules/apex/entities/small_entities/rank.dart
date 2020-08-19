class Rank {
  Rank(this.rankScore, this.rankName, this.rankDiv, this.ladderPos, this.rankImg, this.rankedSeason);

  factory Rank.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Rank(
      json['rankScore'] as int,
      json['rankName'] as String,
      json['rankDiv'] as int,
      json['ladderPos'] as int,
      json['rankImg'] as String,
      json['rankedSeason'] as String,
    );
  }

  int rankScore;
  String rankName;
  int rankDiv;
  int ladderPos;
  String rankImg;
  String rankedSeason;
}
