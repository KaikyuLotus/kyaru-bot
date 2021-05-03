import 'util.dart';

class Character {
  final String id;
  final Map names;
  final String canonicalName;
  final List otherNames;
  final String description;
  final String imageUrl;

  Character(
    this.id,
    this.names,
    this.canonicalName,
    this.otherNames,
    this.description,
    this.imageUrl,
  );

  static Character fromJson(Map<String, dynamic> json) {
    var attributes = json['attributes'];
    return Character(
      json['id'],
      attributes['names'],
      attributes['canonicalName'],
      attributes['otherNames'],
      removeAllHtmlTags(attributes['description']),
      attributes['image']['original'],
    );
  }

  static List<Character> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Character.fromJson(jsonArray[i]),
    );
  }
}
