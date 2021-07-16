class Weapon {
  final String name;
  final String description;
  final String weaponType;
  final int rarity;
  final int baseAtk;
  final String subStat;
  final String subValue;
  final String effectName;
  final String effect;
  final List<List<String>> refinement;
  final String weaponMaterialType;

  Weapon(
    this.name,
    this.description,
    this.weaponType,
    this.rarity,
    this.baseAtk,
    this.subStat,
    this.subValue,
    this.effectName,
    this.effect,
    this.refinement,
    this.weaponMaterialType,
  );

  static Weapon fromJson(Map<String, dynamic> json) {
    var ref = <List<String>>[];
    for (var r = 1; json['r$r'] != null; r++) {
      ref.add(json['r$r'].cast<String>());
    }
    return Weapon(
      json['name'],
      json['description'],
      json['weapontype'],
      int.parse(json['rarity']),
      json['baseatk'],
      json['substat'],
      json['subvalue'],
      json['effectname'],
      json['effect'],
      ref,
      json['weaponmaterialtype'],
    );
  }
}
