class Stats {
  final int activeDayNumber;
  final int achievementNumber;
  final int winRate;
  final int anemoculusNumber;
  final int geoculusNumber;
  final int avatarNumber;
  final int wayPointNumber;
  final int domainNumber;
  final String spiralAbyss;
  final int preciousChestNumber;
  final int luxuriousChestNumber;
  final int exquisiteChestNumber;
  final int commonChestNumber;
  final int electroculusNumber;

  Stats({
    required this.activeDayNumber,
    required this.achievementNumber,
    required this.winRate,
    required this.anemoculusNumber,
    required this.geoculusNumber,
    required this.avatarNumber,
    required this.wayPointNumber,
    required this.domainNumber,
    required this.spiralAbyss,
    required this.preciousChestNumber,
    required this.luxuriousChestNumber,
    required this.exquisiteChestNumber,
    required this.commonChestNumber,
    required this.electroculusNumber,
  });

  static Stats fromJson(Map<String, dynamic> json) {
    return Stats(
      activeDayNumber: json['active_day_number'],
      achievementNumber: json['achievement_number'],
      winRate: json['win_rate'],
      anemoculusNumber: json['anemoculus_number'],
      geoculusNumber: json['geoculus_number'],
      avatarNumber: json['avatar_number'],
      wayPointNumber: json['way_point_number'],
      domainNumber: json['domain_number'],
      spiralAbyss: json['spiral_abyss'],
      preciousChestNumber: json['precious_chest_number'],
      luxuriousChestNumber: json['luxurious_chest_number'],
      exquisiteChestNumber: json['exquisite_chest_number'],
      commonChestNumber: json['common_chest_number'],
      electroculusNumber: json['electroculus_number'],
    );
  }
}
