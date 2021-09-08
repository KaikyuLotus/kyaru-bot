import 'artifact_set.dart';

class Artifact {
  final int id;
  final String name;
  final String icon;
  final int pos;
  final int rarity;
  final int level;
  final ArtifactSet set;

  String get description => '${set.name} +$level';

  Artifact({
    required this.id,
    required this.name,
    required this.icon,
    required this.pos,
    required this.rarity,
    required this.level,
    required this.set,
  });

  static Artifact fromJson(Map<String, dynamic> json) {
    return Artifact(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      pos: json['pos'],
      rarity: json['rarity'],
      level: json['level'],
      set: ArtifactSet.fromJson(json['set']),
    );
  }

  static List<Artifact> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Artifact.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'pos': pos,
      'rarity': rarity,
      'level': level,
      'set': set.toJson(),
    };
  }
}
