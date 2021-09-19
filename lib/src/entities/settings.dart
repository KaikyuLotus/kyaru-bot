import 'package:dart_telegram_bot/telegram_entities.dart';

class Settings {
  final String token;
  final ChatID ownerId;
  final String? lolToken;
  final String? apexToken;
  final String? lastfmToken;
  final String? weatherToken;
  final String? steamToken;
  final String? videogameToken;
  final String? genshinRendererUrl;
  final String? genshinDataUrl;
  final String? githubToken;

  Settings({
    required this.token,
    required this.ownerId,
    this.lolToken,
    this.apexToken,
    this.lastfmToken,
    this.weatherToken,
    this.steamToken,
    this.videogameToken,
    this.genshinDataUrl,
    this.genshinRendererUrl,
    this.githubToken,
  });

  static Settings fromJson(Map<String, dynamic> json) {
    return Settings(
      token: json['token'],
      lolToken: json['lol_token'],
      apexToken: json['apex_token'],
      lastfmToken: json['lastfm_token'],
      weatherToken: json['weather_token'],
      steamToken: json['steam_token'],
      videogameToken: json['videogame_token'],
      genshinDataUrl: json['genshin_data_url'],
      genshinRendererUrl: json['genshin_renderer_url'],
      githubToken: json['github_token'],
      ownerId: ChatID(json['owner_id']),
    );
  }

  Settings copyWith({
    String? token,
    ChatID? ownerId,
    String? lolToken,
    String? apexToken,
    String? lastfmToken,
    String? weatherToken,
    String? steamToken,
    String? videogameToken,
    String? genshinDataUrl,
    String? genshinRendererUrl,
    String? githubToken,
  }) {
    return Settings(
      token: token ?? this.token,
      lolToken: lolToken ?? this.lolToken,
      apexToken: apexToken ?? this.apexToken,
      lastfmToken: lastfmToken ?? this.lastfmToken,
      weatherToken: weatherToken ?? this.weatherToken,
      steamToken: steamToken ?? this.steamToken,
      videogameToken: videogameToken ?? this.videogameToken,
      genshinDataUrl: genshinDataUrl ?? this.genshinDataUrl,
      genshinRendererUrl: genshinRendererUrl ?? this.genshinRendererUrl,
      githubToken: githubToken ?? this.githubToken,
      ownerId: ownerId ?? this.ownerId,
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
      'genshin_data_url': genshinDataUrl,
      'genshin_renderer_url': genshinRendererUrl,
      'github_token': githubToken,
      'owner_id': ownerId.chatId,
    };
  }
}
