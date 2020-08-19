class Champion {
  String id;
  String key;
  String name;
  String title;
  String blurb;

  Champion(this.id, this.key, this.name, this.title, this.blurb);

  factory Champion.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Champion(
      json['id'],
      json['key'],
      json['name'],
      json['title'],
      json['blurb'],
    );
  }

  static List<Champion> listFromResponse(Map<String, dynamic> response) {
    if (response == null) return null;
    var keys = List.from(response['data'].keys);
    return List.generate(keys.length, (i) => Champion.fromJson(response['data'][keys[i]]));
  }
}
