import 'artifact.dart';

class ArtifactSet {
  final String name;
  final List<dynamic> rarity;
  final String twoP;
  final String fourP;
  final List<Artifact> set;

  ArtifactSet(
    this.name,
    this.rarity,
    this.twoP,
    this.fourP,
    this.set,
  );

  static ArtifactSet fromJson(Map<String, dynamic> json) {
    var types = [
      'flower',
      'plume',
      'sands',
      'goblet',
      'circlet',
    ];
    var artifacts = <Artifact>[];
    for (var type in types) {
      if (json[type] != null) {
        artifacts.add(Artifact.fromJson(json[type]));
      }
    }
    return ArtifactSet(
      json['name'],
      json['rarity'],
      json['2pc'],
      json['4pc'],
      artifacts,
    );
  }
}
