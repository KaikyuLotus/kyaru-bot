class Broadcast {
  final int chatId;
  final String city;

  Broadcast(
    this.chatId,
    this.city,
  );

  static Broadcast fromJson(Map<String, dynamic> json) {
    return Broadcast(
      json['chat_id'],
      json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'city': city,
    };
  }
}
