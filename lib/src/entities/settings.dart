import 'package:dart_telegram_bot/telegram_entities.dart';

class Settings {
  String token;
  String? lolToken;
  String? apexToken;
  String? lastfmToken;
  String? weatherToken;
  ChatID ownerId;

  Settings(
    this.token,
    this.lolToken,
    this.apexToken,
    this.lastfmToken,
    this.weatherToken,
    this.ownerId,
  );

  static Settings fromJson(Map<String, dynamic> json) {
    return Settings(
      json['token'],
      json['lol_token'],
      json['apex_token'],
      json['lastfm_token'],
      json['weather_token'],
      ChatID(json['owner_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'lol_token': lolToken,
      'apex_token': apexToken,
      'lastfm_token': lastfmToken,
      'weather_token': weatherToken,
      'owner_id': ownerId.chatId,
    };
  }
}
