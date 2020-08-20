import 'player.dart';

class ParticipantIdentity {
  int participantId;
  Player player;

  ParticipantIdentity(this.participantId, this.player);

  factory ParticipantIdentity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return ParticipantIdentity(
      json['participantId'],
      Player.fromJson(json['player']),
    );
  }

  static List<ParticipantIdentity> listFromJsonArray(dynamic jsonArray) {
    if (jsonArray == null) {
      return null;
    }
    return List.generate(jsonArray.length, (i) => ParticipantIdentity.fromJson(jsonArray[i]));
  }
}
