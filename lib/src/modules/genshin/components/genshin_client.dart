import '../../../../kyaru.dart';
import '../../hoyolab/components/hoyolab_client.dart';
import '../../hoyolab/entities/api_cache.dart';
import '../entities/genshin_entities.dart';

class GenshinClient extends HoyolabClient {
  GenshinClient(Kyaru _kyaru) : super(_kyaru);

  Future<CachedAPIResponse<UserInfo>> getUserData({
    required int userId,
    required int gameId,
  }) async {
    final server = recognizeServer(gameId, genshinServers);

    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;

    var cachedResult = await request(
      endpoint: EndpointName.genshinIndex,
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

  Future<CachedAPIResponse<UserCharacters>> getCharacters({
    required int userId,
    required int gameId,
    required List<int> characterIdsJson,
  }) async {
    final server = recognizeServer(gameId, genshinServers);
    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;
    var cachedResult = await request(
      endpoint: EndpointName.genshinCharacter,
      body: {
        'character_ids': characterIdsJson,
        'server': server,
        'role_id': gameId
      },
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      userId: userId,
      method: 'POST',
    );
    return CachedAPIResponse.fromCachedResult<UserCharacters>(
      cachedResult,
      UserCharacters.fromJson,
    );
  }

  Future<FullAbyssInfo> getSpiralAbyss({
    required int userId,
    required int gameId,
  }) async {
    final server = recognizeServer(gameId, genshinServers);
    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;
    final current = await request(
      endpoint: EndpointName.genshinSpiralAbyss,
      params: {'server': server, 'role_id': '$gameId', 'schedule_type': '1'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      userId: userId,
    );
    final previous = await request(
      endpoint: EndpointName.genshinSpiralAbyss,
      params: {'server': server, 'role_id': '$gameId', 'schedule_type': '2'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      userId: userId,
    );
    return FullAbyssInfo(
      currentPeriod: CachedAPIResponse.fromCachedResult(
        current,
        AbyssInfo.fromJson,
      ),
      previousPeriod: CachedAPIResponse.fromCachedResult(
        previous,
        AbyssInfo.fromJson,
      ),
    );
  }
}
