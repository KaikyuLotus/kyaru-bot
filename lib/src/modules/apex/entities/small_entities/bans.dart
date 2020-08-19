class Bans {
  bool isActive;
  int remainingSeconds;
  String lastBanReason;

  Bans(this.isActive, this.remainingSeconds, this.lastBanReason);

  factory Bans.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Bans(
      json['isActive'],
      json['remainingSeconds'],
      json['last_banReason'],
    );
  }
}
