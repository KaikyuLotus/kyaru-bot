import '../../../../kyaru.dart';
import '../../hoyolab/components/hoyolab_client.dart';
import '../../hoyolab/entities/api_cache.dart';
import '../entities/star_rail_entities.dart';

class StarRailClient extends HoyolabClient {
  StarRailClient(Kyaru _kyaru) : super(_kyaru);

  Future<CachedAPIResponse<UserInfo>> getUserIndex({
    required int userId,
    required int gameId,
  }) async {
    final server = recognizeServer(gameId, hsrServers);

    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;

    var cachedResult = await request(
      endpoint: EndpointName.hsrIndex,
      params: {'server': server, 'role_id': '$gameId'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      userId: userId,
    );
    return CachedAPIResponse.fromCachedResult<UserInfo>(
      cachedResult,
      UserInfo.fromJson,
    );
  }

  // This works only if the token used is of the user queried
  Future<CachedAPIResponse<UserInfo>> getUserNote({
    required int userId,
    required int gameId,
  }) async {
    final server = recognizeServer(gameId, hsrServers);

    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;

    var cachedResult = await request(
      endpoint: EndpointName.hsrNote,
      params: {'server': server, 'role_id': '$gameId'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      userId: userId,
    );
    return CachedAPIResponse.fromCachedResult<UserInfo>(
      cachedResult,
      UserInfo.fromJson,
    );
  }

  Future<CachedAPIResponse<List<Avatar>>> getUserInfo({
    required int userId,
    required int gameId,
  }) async {
    final server = recognizeServer(gameId, hsrServers);

    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;

    var cachedResult = await request(
      endpoint: EndpointName.hsrInfo,
      params: {'server': server, 'role_id': '$gameId'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      userId: userId,
    );
    return CachedAPIResponse.fromCachedResult<List<Avatar>>(
      cachedResult,
      (data) =>
          data['avatar_list'].map<Avatar>((e) => Avatar.fromJson(e)).toList(),
    );
  }
}
