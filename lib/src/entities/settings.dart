import 'package:dart_telegram_bot/telegram_entities.dart';

class Settings {
  String token;
  String? lolToken;
  String? apexToken;
  String? lastfmToken;
  String? weatherToken;
  String? steamToken;
  String? videogameToken;
  String? genshinUrl;
  ChatID ownerId;

  Settings(
    this.token,
    this.lolToken,
    this.apexToken,
    this.lastfmToken,
    this.weatherToken,
    this.steamToken,
    this.videogameToken,
    this.genshinUrl,
    this.ownerId,
  );

  static Settings fromJson(Map<String, dynamic> json) {
    return Settings(
      json['token'],
      json['lol_token'],
      json['apex_token'],
      json['lastfm_token'],
      json['weather_token'],
      json['steam_token'],
      json['videogame_token'],
      json['genshin_url'],
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
      'steam_token': steamToken,
      'videogame_token': videogameToken,
      'genshin_url': genshinUrl,
      'owner_id': ownerId.chatId,
    };
  }
}
