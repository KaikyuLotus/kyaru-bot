class Genre {
  final int id;
  final String name;
  final String slug;
  final int gamesCount;

  Genre(
    this.id,
    this.name,
    this.slug,
    this.gamesCount,
  );

  static Genre fromJson(Map<String, dynamic> json) {
    return Genre(
      json['id'],
      json['name'],
      json['slug'],
      json['games_count'],
    );
  }

  static List<Genre> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Genre.fromJson(jsonArray[i]),
    );
  }
}
