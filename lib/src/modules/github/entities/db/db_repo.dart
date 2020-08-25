class DBRepo {
  int chatID;
  String repo;
  String user;

  DBRepo(this.chatID, this.user, this.repo);

  static DBRepo fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return DBRepo(
      json['chat_id'],
      json['user'],
      json['repo'],
    );
  }

  static List<DBRepo> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) {
      return null;
    }
    return List.generate(jsonArray.length, (i) => DBRepo.fromJson(jsonArray[i]));
  }

  Map<String, dynamic> toJson() {
    return {'chat_id': chatID, 'repo': repo, 'user': user};
  }
}
