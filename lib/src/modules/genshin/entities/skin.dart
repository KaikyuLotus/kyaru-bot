class Skin {
  final int id;
  final String name;
  final String icon;

  Skin({
    required this.id,
    required this.name,
    required this.icon,
  });

  static Skin fromJson(Map<String, dynamic> json) {
    return Skin(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }

  static List<Skin> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Skin.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}
