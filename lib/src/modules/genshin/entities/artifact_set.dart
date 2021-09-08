import 'artifact_affix.dart';

class ArtifactSet {
  final int id;
  final String name;
  List<ArtifactAffix> affixes;

  ArtifactSet({
    required this.id,
    required this.name,
    required this.affixes,
  });

  static ArtifactSet fromJson(Map<String, dynamic> json) {
    return ArtifactSet(
      id: json['id'],
      name: json['name'],
      affixes: ArtifactAffix.listFromJsonArray(json['affixes']),
    );
  }

  static List<ArtifactSet> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => ArtifactSet.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'affixes': affixes.map((a) => a.toJson()).toList(),
    };
  }
}
