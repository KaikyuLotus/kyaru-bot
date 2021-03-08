class UserSinoAliceData {
  int? userId;
  String? gameId;

  UserSinoAliceData(this.userId, this.gameId);

  static UserSinoAliceData fromJson(Map<String, dynamic> json) {
    return UserSinoAliceData(json['user_id'], json['game_id']);
  }

  static List<UserSinoAliceData> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => UserSinoAliceData.fromJson(jsonArray[i]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'game_id': gameId,
    };
  }
}
