class Home {
  final int level;
  final int visitNum;
  final int comfortNum;
  final int itemNum;
  final String name;
  final String icon;
  final String comfortLevelName;
  final String comfortLevelIcon;

  Home({
    required this.level,
    required this.visitNum,
    required this.comfortNum,
    required this.itemNum,
    required this.name,
    required this.icon,
    required this.comfortLevelName,
    required this.comfortLevelIcon,
  });

  static Home fromJson(Map<String, dynamic> json) {
    return Home(
      level: json['level'],
      visitNum: json['visit_num'],
      comfortNum: json['comfort_num'],
      itemNum: json['item_num'],
      name: json['name'],
      icon: json['icon'],
      comfortLevelName: json['comfort_level_name'],
      comfortLevelIcon: json['comfort_level_icon'],
    );
  }

  static List<Home> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Home.fromJson(json[index]));
  }
}
