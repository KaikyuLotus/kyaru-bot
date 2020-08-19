class Team {
  int teamId;
  String win;
  bool firstBlood;
  bool firstTower;
  bool firstInhibitor;
  bool firstBaron;
  bool firstDragon;
  bool firstRiftHerald;
  int towerKills;
  int inhibitorKills;
  int baronKills;
  int dragonKills;
  int vilemawKills;
  int riftHeraldKills;
  int dominionVictoryScore;

  Team(
    this.teamId,
    this.win,
    this.firstBlood,
    this.firstTower,
    this.firstInhibitor,
    this.firstBaron,
    this.firstDragon,
    this.firstRiftHerald,
    this.towerKills,
    this.inhibitorKills,
    this.baronKills,
    this.dragonKills,
    this.vilemawKills,
    this.riftHeraldKills,
    this.dominionVictoryScore,
  );

  factory Team.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Team(
      json['teamId'],
      json['win'],
      json['firstBlood'],
      json['firstTower'],
      json['firstInhibitor'],
      json['firstBaron'],
      json['firstDragon'],
      json['firstRiftHerald'],
      json['towerKills'],
      json['inhibitorKills'],
      json['baronKills'],
      json['dragonKills'],
      json['vilemawKills'],
      json['riftHeraldKills'],
      json['dominionVictoryScore'],
    );
  }

  static List<Team> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return null;
    return List.generate(jsonArray.length, (i) => Team.fromJson(jsonArray[i]));
  }
}
