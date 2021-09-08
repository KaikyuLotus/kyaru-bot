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
  String? genshinRendererUrl;
  String? genshinDataUrl;
  String? githubToken;
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
    this.genshinDataUrl,
    this.genshinRendererUrl,
    this.githubToken,
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
      json['genshin_data_url'],
      json['genshin_renderer_url'],
      json['github_token'],
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
      'genshin_data_url': genshinDataUrl,
      'genshin_renderer_url': genshinRendererUrl,
      'github_token': githubToken,
      'owner_id': ownerId.chatId,
    };
  }
}
