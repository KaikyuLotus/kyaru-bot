class ChatData {
  int? id;
  bool? nsfw;

  ChatData(this.id, {this.nsfw});

  static ChatData fromJson(Map<String, dynamic> json) {
    return ChatData(
      json['id'],
      nsfw: json['nsfw'] ?? false,
    );
  }

  static List<ChatData> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
        jsonArray.length, (i) => ChatData.fromJson(jsonArray[i]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nsfw': nsfw,
    };
  }
}
