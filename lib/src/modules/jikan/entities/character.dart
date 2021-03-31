import 'summary.dart';

class Character {
  int? malId;
  String? url;
  String? imageUrl;
  String? name;
  List<dynamic> alternativeNames;
  List<Summary> anime;
  List<Summary> manga;

  Character(
    this.malId,
    this.url,
    this.imageUrl,
    this.name,
    this.alternativeNames,
    this.anime,
    this.manga,
  );

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      json['mal_id'],
      json['url'],
      json['image_url'],
      json['name'],
      json['alternative_names'],
      Summary.listFromJsonArray(json['anime']),
      Summary.listFromJsonArray(json['manga']),
    );
  }

  static List<Character> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Character.fromJson(jsonArray[i]),
    );
  }
}
