import 'offering.dart';

class WorldExploration {
  final int id;
  final int level;
  final int explorationPercentage;
  final String icon;
  final String name;
  final String type;
  final List<Offering> offerings;

  double get percentage => explorationPercentage / 10;

  Offering get inazumaTree => offeringWithName(inazumaTreeName);
  String get inazumaTreeName => "Sacred Sakura's Favor";

  Offering get dragonspineTree => offeringWithName(dragonspineTreeName);
  String get dragonspineTreeName => "Frostbearing Tree";

  WorldExploration({
    required this.id,
    required this.level,
    required this.explorationPercentage,
    required this.icon,
    required this.name,
    required this.type,
    required this.offerings,
  });

  Offering offeringWithName(String name) {
    return offerings.firstWhere((e) => e.name == name);
  }

  static WorldExploration fromJson(Map<String, dynamic> json) {
    return WorldExploration(
      id: json['id'],
      level: json['level'],
      explorationPercentage: json['exploration_percentage'],
      icon: json['icon'],
      name: json['name'],
      type: json['type'],
      offerings: Offering.listFromJsonArray(json['offerings']),
    );
  }

  static List<WorldExploration> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => WorldExploration.fromJson(json[index]),
    );
  }
}
