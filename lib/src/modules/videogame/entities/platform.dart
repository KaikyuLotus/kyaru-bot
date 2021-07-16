class Platform {
  final int id;
  final String name;
  final String slug;
  final int gamesCount;

  Platform(
    this.id,
    this.name,
    this.slug,
    this.gamesCount,
  );

  static Platform fromJson(Map<String, dynamic> json) {
    return Platform(
      json['id'],
      json['name'],
      json['slug'],
      json['games_count'],
    );
  }

  static List<Platform> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Platform.fromJson(jsonArray[i]),
    );
  }
}
