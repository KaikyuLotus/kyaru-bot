class ChatData {
  final int id;
  bool nsfw;
  bool isPrivate;

  ChatData(this.id, {required this.nsfw, required this.isPrivate});

  static ChatData fromJson(Map<String, dynamic> json) {
    return ChatData(
      json['id'],
      nsfw: json['nsfw'] ?? false,
      isPrivate: json['is_private'] ?? false,
    );
  }

  static List<ChatData> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => ChatData.fromJson(jsonArray[i]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nsfw': nsfw,
      'is_private': isPrivate,
    };
  }
}
