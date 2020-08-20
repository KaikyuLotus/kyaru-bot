class Rank {
  int rankScore;
  String rankName;
  int rankDiv;
  int ladderPos;
  String rankImg;
  String rankedSeason;

  Rank(this.rankScore, this.rankName, this.rankDiv, this.ladderPos, this.rankImg, this.rankedSeason);

  factory Rank.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Rank(
      json['rankScore'],
      json['rankName'],
      json['rankDiv'],
      json['ladderPos'],
      json['rankImg'],
      json['rankedSeason'],
    );
  }
}
