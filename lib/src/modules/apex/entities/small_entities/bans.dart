class Bans {
  bool? isActive;
  int? remainingSeconds;
  String? lastBanReason;

  Bans(
    this.remainingSeconds,
    this.lastBanReason, {
    this.isActive,
  });

  static Bans fromJson(Map<String, dynamic> json) {
    return Bans(
      json['remainingSeconds'],
      json['last_banReason'],
      isActive: json['isActive'],
    );
  }
}
