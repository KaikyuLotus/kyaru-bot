class Constellation {
  final int id;
  final String name;
  final String icon;
  final String effect;
  final bool isActived;
  final int pos;

  Constellation({
    required this.id,
    required this.name,
    required this.icon,
    required this.effect,
    required this.isActived,
    required this.pos,
  });

  static Constellation fromJson(Map<String, dynamic> json) {
    return Constellation(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      effect: json['effect'],
      isActived: json['is_actived'],
      pos: json['pos'],
    );
  }

  static List<Constellation> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Constellation.fromJson(json[index]),
    );
  }
}
