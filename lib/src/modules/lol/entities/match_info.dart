import 'participant.dart';
import 'participant_identity.dart';
import 'team.dart';

class MatchInfo {
  int? gameId;
  String? platformId;
  DateTime gameCreation;
  int gameDuration;
  int? queueId;
  int? mapId;
  int? seasonId;
  String? gameVersion;
  String? gameMode;
  String? gameType;
  List<Team> teams;
  List<Participant> participants;
  List<ParticipantIdentity> participantIdentities;

  MatchInfo(
    this.gameId,
    this.platformId,
    this.gameCreation,
    this.gameDuration,
    this.queueId,
    this.mapId,
    this.seasonId,
    this.gameVersion,
    this.gameMode,
    this.gameType,
    this.teams,
    this.participants,
    this.participantIdentities,
  );

  static MatchInfo fromJson(Map<String, dynamic> json) {
    return MatchInfo(
      json['gameId'],
      json['platformId'],
      DateTime.fromMillisecondsSinceEpoch(json['gameCreation']),
      json['gameDuration'],
      json['queueId'],
      json['mapId'],
      json['seasonId'],
      json['gameVersion'],
      json['gameMode'],
      json['gameType'],
      Team.listFromJsonArray(json['teams'] ?? []),
      Participant.listFromJsonArray(json['participants'] ?? []),
      ParticipantIdentity.listFromJsonArray(
        json['participantIdentities'] ?? [],
      ),
    );
  }
}
