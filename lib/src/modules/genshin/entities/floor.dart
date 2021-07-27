import 'level.dart';

class Floor {
  final int index; // 9,
  final String icon; // "",
  final bool isUnlock; // true,
  final String settleTime; // "0",
  final int star; // 9,
  final int maxStar; // 9,
  final List<Level> levels;

  Floor({
    required this.index,
    required this.icon,
    required this.isUnlock,
    required this.settleTime,
    required this.star,
    required this.maxStar,
    required this.levels,
  }); // [

  static Floor fromJson(Map<String, dynamic> json) {
    return Floor(
      index: json['index'],
      icon: json['icon'],
      isUnlock: json['is_unlock'],
      settleTime: json['settle_time'],
      star: json['star'],
      maxStar: json['max_star'],
      levels: Level.listFromJsonArray(json['levels']),
    );
  }

  static List<Floor> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Floor.fromJson(json[index]));
  }

}
