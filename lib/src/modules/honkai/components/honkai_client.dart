import '../../../../kyaru.dart';
import '../../hoyolab/components/hoyolab_client.dart';
import '../../hoyolab/entities/api_cache.dart';
import '../entities/honkai_entities.dart';

const settingsEu = ServerSettings(
  salt: "6s25p5ox5y14umn1p61aqyyvbvvl3lrt",
  host: "bbs-api-os.hoyolab.com",
  rpcVer: "1.5.0",
  clientType: "5",
  lang: 'en-us',
  endpoints: {
    EndpointName.character: "/game_record/honkai3rd/api/characters",
  },
);

class HonkaiClient extends HoyolabClient {
  HonkaiClient(Kyaru _kyaru) : super(_kyaru);

  Future<CachedAPIResponse<UserCharacters>> getCharacters({
    required int userId,
    required int gameId,
  }) async {
    var cachedResult = await request(
      endpoint: EndpointName.character,
      //TODO: Server
      params: {'server': 'eur01', 'role_id': '$gameId'},
      gameId: gameId,
      settings: settingsEu,
      userId: userId,
    );

    return CachedAPIResponse.fromCachedResult<UserCharacters>(
      cachedResult,
      UserCharacters.fromJson,
    );
  }

  Future<CachedAPIResponse<UserInfo>> getUserData({
    required int userId,
    required int gameId,
  }) async {
    var cachedResult = await request(
        endpoint: EndpointName.indexPage,
        params: {'server': 'eur01', 'role_id': '$gameId'},
        userId: userId,
        gameId: gameId,
        settings: settingsEu);
    return CachedAPIResponse.fromCachedResult<UserInfo>(
      cachedResult,
      UserInfo.fromJson,
    );
  }
}
