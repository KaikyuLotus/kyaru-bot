class ChatData {
  int id;
  bool nsfw;

  ChatData(this.id, this.nsfw);

  factory ChatData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ChatData(
      json['id'],
      json['nsfw'] ?? false,
    );
  }

  static List<ChatData> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return null;
    return List.generate(jsonArray.length, (i) => ChatData.fromJson(jsonArray[i]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nsfw': nsfw,
    };
  }
}
