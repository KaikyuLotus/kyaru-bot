class VideogameDetails {
  final int id;
  final String slug;
  final String name;
  final String nameOriginal;
  final String description;

  VideogameDetails(
    this.id,
    this.slug,
    this.name,
    this.nameOriginal,
    this.description,
  );

  static VideogameDetails fromJson(Map<String, dynamic> json) {
    return VideogameDetails(
      json['id'],
      json['slug'],
      json['name'],
      json['name_original'],
      json['description'],
    );
  }
}
