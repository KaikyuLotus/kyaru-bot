import 'participant.dart';
import 'team.dart';

class MatchInfo {
  int? gameId;
  String? platformId;
  DateTime gameCreation;
  int gameDuration;
  int? queueId;
  int? mapId;
  String? gameVersion;
  String? gameMode;
  String? gameType;
  List<Team> teams;
  List<Participant> participants;

  MatchInfo(
    this.gameId,
    this.platformId,
    this.gameCreation,
    this.gameDuration,
    this.queueId,
    this.mapId,
    this.gameVersion,
    this.gameMode,
    this.gameType,
    this.teams,
    this.participants,
  );

  static MatchInfo fromJson(Map<String, dynamic> json) {
    json = json['info'];
    return MatchInfo(
      json['gameId'],
      json['platformId'],
      DateTime.fromMillisecondsSinceEpoch(json['gameCreation']),
      json['gameDuration'],
      json['queueId'],
      json['mapId'],
      json['gameVersion'],
      json['gameMode'],
      json['gameType'],
      Team.listFromJsonArray(json['teams'] ?? []),
      Participant.listFromJsonArray(json['participants'] ?? []),
    );
  }
}
