class Rank {
  final int avatarId;
  final String avatarIcon;
  final int value;
  final int rarity;

  String get name {
    if (avatarIcon.contains('Side')) {
      return avatarIcon.split("Side_")[1].split(".")[0];
    }
    return avatarIcon.split("AvatarIcon_")[1].split(".")[0];
  }

  Rank({
    required this.avatarId,
    required this.avatarIcon,
    required this.value,
    required this.rarity,
  });

  static Rank fromJson(Map<String, dynamic> json) {
    return Rank(
      avatarId: json['avatar_id'],
      avatarIcon: json['avatar_icon'],
      value: json['value'],
      rarity: json['rarity'],
    );
  }

  static List<Rank> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Rank.fromJson(json[index]));
  }
}
