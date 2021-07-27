class Offering {
  final String name;
  final int level;

  Offering({
    required this.name,
    required this.level,
  });

  static Offering fromJson(Map<String, dynamic> json) {
    return Offering(
      name: json['name'],
      level: json['level'],
    );
  }

  static List<Offering> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Offering.fromJson(json[index]),
    );
  }
}
