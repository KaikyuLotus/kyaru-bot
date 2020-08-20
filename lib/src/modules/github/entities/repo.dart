class Repo {
  int id;
  String name;
  String url;

  Repo(this.id, this.name, this.url);

  factory Repo.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Repo(
      json['id'],
      json['name'],
      json['url'],
    );
  }
}
