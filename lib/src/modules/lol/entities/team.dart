import 'objective.dart';

class Team {
  int? teamId;
  bool? win;
  Objective baron;
  Objective champion;
  Objective dragon;
  Objective inhibitor;
  Objective riftHerald;
  Objective tower;

  Team(
    this.teamId,
    this.win,
    this.baron,
    this.champion,
    this.dragon,
    this.inhibitor,
    this.riftHerald,
    this.tower,
  );

  static Team fromJson(Map<String, dynamic> json) {
    var objectives = json['objectives'];
    return Team(
      json['teamId'],
      json['win'],
      Objective.fromJson(objectives['baron']),
      Objective.fromJson(objectives['champion']),
      Objective.fromJson(objectives['dragon']),
      Objective.fromJson(objectives['inhibitor']),
      Objective.fromJson(objectives['riftHerald']),
      Objective.fromJson(objectives['tower']),
    );
  }

  static List<Team> listFromJsonArray(dynamic jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Team.fromJson(jsonArray[i]),
    );
  }
}
