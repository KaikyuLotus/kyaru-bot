class DBRepo {
  int? chatID;
  String? repo;
  String? user;

  DBRepo(this.chatID, this.user, this.repo);

  static DBRepo fromJson(Map<String, dynamic> json) {
    return DBRepo(
      json['chat_id'],
      json['user'],
      json['repo'],
    );
  }

  static List<DBRepo> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => DBRepo.fromJson(jsonArray[i]),
    );
  }

  Map<String, dynamic> toJson() {
    return {'chat_id': chatID, 'repo': repo, 'user': user};
  }

  @override
  String toString() {
    return '$chatID$repo$user';
  }
}
