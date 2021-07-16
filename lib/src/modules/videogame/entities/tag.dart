class Tag {
  final int id;
  final String name;
  final String slug;
  final String language;
  final int gamesCount;

  Tag(
    this.id,
    this.name,
    this.slug,
    this.language,
    this.gamesCount,
  );

  static Tag fromJson(Map<String, dynamic> json) {
    return Tag(
      json['id'],
      json['name'],
      json['slug'],
      json['language'],
      json['games_count'],
    );
  }

  static List<Tag> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Tag.fromJson(jsonArray[i]),
    );
  }
}
