class Repo {
  int? id;
  String? name;
  String? url;

  Repo(this.id, this.name, this.url);

  static Repo fromJson(Map<String, dynamic> json) {
    return Repo(
      json['id'],
      json['name'],
      json['url'],
    );
  }
}
