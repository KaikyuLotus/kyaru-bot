class Bans {
  bool isActive;
  int remainingSeconds;
  String lastBanReason;

  Bans(
    this.remainingSeconds,
    this.lastBanReason, {
    this.isActive,
  });

  factory Bans.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Bans(
      json['remainingSeconds'],
      json['last_banReason'],
      isActive: json['isActive'],
    );
  }
}
