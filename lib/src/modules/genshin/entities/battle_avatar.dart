class BattleAvatar {
  final int id;
  final String icon;
  final int level;
  final int rarity;

  BattleAvatar({
    required this.id,
    required this.icon,
    required this.level,
    required this.rarity,
  });

  static BattleAvatar fromJson(Map<String, dynamic> json) {
    return BattleAvatar(
      id: json['id'],
      icon: json['icon'],
      level: json['level'],
      rarity: json['id'],
    );
  }

  static List<BattleAvatar> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => BattleAvatar.fromJson(json[index]),
    );
  }
}
