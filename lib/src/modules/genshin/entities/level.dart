import 'battle.dart';

class Level {
  final int index;
  final int star;
  final int maxStar;
  final List<Battle> battles;

  Level({
    required this.index,
    required this.star,
    required this.maxStar,
    required this.battles,
  });

  static Level fromJson(Map<String, dynamic> json) {
    return Level(
      index: json['index'],
      star: json['star'],
      maxStar: json['max_star'],
      battles: Battle.listFromJsonArray(json['battles']),
    );
  }

  static List<Level> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Level.fromJson(json[index]));
  }
}
