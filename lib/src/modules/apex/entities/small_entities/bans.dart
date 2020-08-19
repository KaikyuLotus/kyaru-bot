class Bans {

  Bans(this.isActive, this.remainingSeconds, this.lastBanReason);

  factory Bans.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Bans(
      json['isActive'] as bool,
      json['remainingSeconds'] as int,
      json['last_banReason'] as String,
    );
  }

  bool isActive;
  int remainingSeconds;
  String lastBanReason;

}
