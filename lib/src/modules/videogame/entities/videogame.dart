class Videogame {
  final int id;
  final String slug;
  final String name;

  Videogame(
    this.id,
    this.slug,
    this.name,
  );

  static Videogame fromJson(Map<String, dynamic> json) {
    return Videogame(
      json['id'],
      json['slug'],
      json['name'],
    );
  }
}
