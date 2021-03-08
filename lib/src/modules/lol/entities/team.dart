class Team {
  int? teamId;
  String? win;
  bool? firstBlood;
  bool? firstTower;
  bool? firstInhibitor;
  bool? firstBaron;
  bool? firstDragon;
  bool? firstRiftHerald;
  int? towerKills;
  int? inhibitorKills;
  int? baronKills;
  int? dragonKills;
  int? vilemawKills;
  int? riftHeraldKills;
  int? dominionVictoryScore;

  Team(
    this.teamId,
    this.win,
    this.towerKills,
    this.inhibitorKills,
    this.baronKills,
    this.dragonKills,
    this.vilemawKills,
    this.riftHeraldKills,
    this.dominionVictoryScore, {
    this.firstBaron,
    this.firstDragon,
    this.firstRiftHerald,
    this.firstInhibitor,
    this.firstTower,
    this.firstBlood,
  });

  static Team fromJson(Map<String, dynamic> json) {
    return Team(
      json['teamId'],
      json['win'],
      json['towerKills'],
      json['inhibitorKills'],
      json['baronKills'],
      json['dragonKills'],
      json['vilemawKills'],
      json['riftHeraldKills'],
      json['dominionVictoryScore'],
      firstBlood: json['firstBlood'],
      firstTower: json['firstTower'],
      firstInhibitor: json['firstInhibitor'],
      firstBaron: json['firstBaron'],
      firstDragon: json['firstDragon'],
      firstRiftHerald: json['firstRiftHerald'],
    );
  }

  static List<Team> listFromJsonArray(dynamic jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Team.fromJson(jsonArray[i]),
    );
  }
}
