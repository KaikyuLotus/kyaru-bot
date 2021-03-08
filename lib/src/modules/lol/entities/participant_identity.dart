import 'player.dart';

class ParticipantIdentity {
  int? participantId;
  Player player;

  ParticipantIdentity(this.participantId, this.player);

  static ParticipantIdentity fromJson(Map<String, dynamic> json) {
    return ParticipantIdentity(
      json['participantId'],
      Player.fromJson(json['player']),
    );
  }

  static List<ParticipantIdentity> listFromJsonArray(dynamic jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => ParticipantIdentity.fromJson(jsonArray[i]),
    );
  }
}
