class Summoner {
  String? id;
  String? accountId;
  String? puuid;
  String? name;
  int? profileIconId;
  int? revisionDate;
  int? summonerLevel;

  Summoner(
    this.id,
    this.accountId,
    this.puuid,
    this.name,
    this.profileIconId,
    this.revisionDate,
    this.summonerLevel,
  );

  factory Summoner.fromJson(dynamic json) {
    return Summoner(
      json['id'],
      json['accountId'],
      json['puuid'],
      json['name'],
      json['profileIconId'],
      json['revisionDate'],
      json['summonerLevel'],
    );
  }
}
