class Weapon {
  final int id;
  final String name;
  final String icon;
  final int type;
  final int rarity;
  final int level;
  final int promoteLevel;
  final String typeName;
  final String desc;
  final int affixLevel;

  String get line1 => 'Ascend $promoteLevel - Level $level';
  String get line2 => 'Refinement $affixLevel';

  Weapon({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.level,
    required this.promoteLevel,
    required this.typeName,
    required this.desc,
    required this.affixLevel,
  });

  static Weapon fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
      rarity: json['rarity'],
      level: json['level'],
      promoteLevel: json['promote_level'],
      typeName: json['type_name'],
      desc: json['desc'],
      affixLevel: json['affix_level'],
    );
  }

  static List<Weapon> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Weapon.fromJson(json[index]),
    );
  }
}
