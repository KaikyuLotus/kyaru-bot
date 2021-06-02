class User {
  final String steamId;
  final int profileState;
  final String personaName;
  final String profileUrl;
  final String avatar;
  final String avatarMedium;
  final String avatarFull;
  final String? primaryClanId;
  final int lastLogOff;
  final int timeCreated;
  final int communityVisibilityState;
  final int commentPermission;

  User(
    this.steamId,
    this.profileState,
    this.personaName,
    this.profileUrl,
    this.avatar,
    this.avatarMedium,
    this.avatarFull,
    this.primaryClanId,
    this.lastLogOff,
    this.timeCreated,
    this.communityVisibilityState,
    this.commentPermission,
  );

  static User fromJson(Map<String, dynamic> json) {
    return User(
      json['steamid'],
      json['profilestate'],
      json['personaname'],
      json['profileurl'],
      json['avatar'],
      json['avatarmedium'],
      json['avatarfull'],
      json['primaryclanid'],
      json['lastlogoff'],
      json['timecreated'],
      json['communityvisibilitystate'],
      json['commentpermission'],
    );
  }
}
