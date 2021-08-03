class Artifact {
  final String name;
  final String relictype;
  final String description;

  Artifact(
    this.name,
    this.relictype,
    this.description,
  );

  static Artifact fromJson(Map<String, dynamic> json) {
    return Artifact(
      json['name'],
      json['relictype'],
      json['description'],
    );
  }
}
