class Stats {
  final int level;
  final int ascension;
  final int hp;
  final int attack;
  final int defense;
  final double specialized;

  Stats(
    this.level,
    this.ascension,
    this.hp,
    this.attack,
    this.defense,
    this.specialized,
  );

  static Stats fromJson(Map<String, dynamic> json) {
    return Stats(
      json['level'],
      json['ascension'],
      json['hp'].toInt(),
      json['attack'].toInt(),
      json['defense'].toInt(),
      json['specialized'].toDouble(),
    );
  }
}
