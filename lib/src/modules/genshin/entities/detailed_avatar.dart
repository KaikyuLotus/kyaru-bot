import 'avatar.dart';
import 'skin.dart';
import 'weapon.dart';
import 'artifact.dart';
import 'constellation.dart';

class DetailedAvatar extends Avatar {
  final Weapon weapon;
  final List<Artifact> artifacts;
  final List<Constellation> constellations;
  final List<Skin> skins;

  DetailedAvatar({
    required id,
    required image,
    required name,
    required element,
    required fetter,
    required level,
    required rarity,
    required activedConstellationNum,
    required this.weapon,
    required this.artifacts,
    required this.constellations,
    required this.skins,
  }) : super(
          id: id,
          image: image,
          name: name,
          element: element,
          fetter: fetter,
          level: level,
          rarity: rarity,
          activedConstellationNum: activedConstellationNum,
        );

  static DetailedAvatar fromJson(Map<String, dynamic> json) {
    return DetailedAvatar(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      element: json['element'],
      fetter: json['fetter'],
      level: json['level'],
      rarity: json['rarity'],
      activedConstellationNum: json['actived_constellation_num'],
      weapon: Weapon.fromJson(json['weapon']),
      artifacts: Artifact.listFromJsonArray(json['reliquaries']),
      constellations: Constellation.listFromJsonArray(json['constellations']),
      skins: Skin.listFromJsonArray(json['costumes']),
    );
  }

  static List<DetailedAvatar> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => DetailedAvatar.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'element': element,
      'fetter': fetter,
      'level': level,
      'rarity': rarity,
      'actived_constellation_num': activedConstellationNum,
      'weapon': weapon.toJson(),
      'reliquaries': artifacts.map((a) => a.toJson()).toList(),
      'constellations': constellations.map((c) => c.toJson()).toList(),
      'costumes': skins.map((s) => s.toJson()).toList(),
    };
  }
}
