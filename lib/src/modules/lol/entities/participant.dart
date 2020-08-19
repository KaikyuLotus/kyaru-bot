import 'participant_stats.dart';

class Participant {
  int participantId;
  int teamId;
  int championId;
  int spell1Id;
  int spell2Id;
  ParticipantStats stats;

  Participant(this.participantId, this.teamId, this.championId, this.spell1Id, this.spell2Id, this.stats);

  factory Participant.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Participant(
      json['participantId'],
      json['teamId'],
      json['championId'],
      json['spell1Id'],
      json['spell2Id'],
      ParticipantStats.fromJson(json['stats']),
    );
  }

  static List<Participant> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return null;
    return List.generate(jsonArray.length, (i) => Participant.fromJson(jsonArray[i]));
  }
}
