class Avatar {
  final int id;
  final String image;
  final String name;
  final String element;
  final int fetter;
  final int level;
  final int rarity;
  final int activedConstellationNum;

  Avatar({
    required this.id,
    required this.image,
    required this.name,
    required this.element,
    required this.fetter,
    required this.level,
    required this.rarity,
    required this.activedConstellationNum,
  });

  static Avatar fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      element: json['element'],
      fetter: json['fetter'],
      level: json['level'],
      rarity: json['rarity'],
      activedConstellationNum: json['actived_constellation_num'],
    );
  }

  static List<Avatar> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Avatar.fromJson(json[index]),
    );
  }
}
