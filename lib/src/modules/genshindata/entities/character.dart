import '../../../utils.dart';

import 'stats.dart';

class Character {
  final String name;
  final String title;
  final String description;
  final int rarity;
  final String element;
  final String weaponType;
  final String subStat;
  final Map<String, dynamic> images;
  final Stats? stats;

  Character(
    this.name,
    this.title,
    this.description,
    this.rarity,
    this.element,
    this.weaponType,
    this.subStat,
    this.images,
    this.stats,
  );

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
        json['name'],
        json['title'],
        json['description'],
        int.parse(json['rarity']),
        json['element'],
        json['weapontype'],
        json['substat'],
        json['images'],
        callIfNotNull(Stats.fromJson, json['stats']));
  }
}
