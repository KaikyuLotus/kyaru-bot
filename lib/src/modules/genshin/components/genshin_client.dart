import '../../../../kyaru.dart';
import '../../hoyolab/components/hoyolab_client.dart';
import '../entities/genshin_entities.dart';

const settingsEu = ServerSettings(
  salt: "6cqshh5dhw73bzxn20oexa9k516chk7s",
  host: "bbs-api-os.hoyolab.com",
  rpcVer: "1.5.0",
  clientType: "4",
  lang: 'en-us',
  endpoints: {
    EndpointName.indexPage: "/game_record/genshin/api/index",
    EndpointName.character: "/game_record/genshin/api/character",
    EndpointName.spiralAbyss: "/game_record/genshin/api/spiralAbyss",
  },
);

const settingsCn = ServerSettings(
  salt: "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs",
  host: "api-takumi.mihoyo.com",
  rpcVer: "2.11.1",
  clientType: "5",
  lang: 'zh-CN,en-US;q=0.8',
  endpoints: {
    EndpointName.indexPage: "/game_record/app/genshin/api/index",
    EndpointName.character: "/game_record/app/genshin/api/character",
    EndpointName.spiralAbyss: "/game_record/app/genshin/api/spiralAbyss",
  },
);

const _servers = <int, String>{
  1: 'cn_gf01',
  5: 'cn_qd01',
  6: 'os_usa',
  7: 'os_euro',
  8: 'os_asia',
  9: 'os_cht',
};

bool isChineseServer(String server) => server.startsWith(RegExp(r'(cn|1|5)'));

class GenshinClient extends HoyolabClient {
  GenshinClient(Kyaru _kyaru) : super(_kyaru);

  Future<CachedAPIResponse<UserInfo>> getUserData({
    required int gameId,
  }) async {
    final server = recognizeServer(gameId);

    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;

    var cachedResult = await request(
        endpoint: EndpointName.indexPage,
        params: {'server': server, 'role_id': '$gameId'},
        gameId: gameId,
        settings: settings,
        chinese: chinese);
    return CachedAPIResponse.fromCachedResult<UserInfo>(
      cachedResult,
      UserInfo.fromJson,
    );
  }

  String? tryRecognizeServer(int gameId) {
    try {
      return recognizeServer(gameId);
    } on UnknownServerForGameIdException {
      return null;
    }
  }

  String recognizeServer(int gameId) {
    final server = _servers[int.parse('$gameId'[0])]; // first digit
    if (server == null) {
      throw UnknownServerForGameIdException(gameId);
    }
    return server;
  }

  Future<CachedAPIResponse<UserCharacters>> getCharacters({
    required int gameId,
    required List<int> characterIdsJson,
  }) async {
    final server = recognizeServer(gameId);
    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;
    var cachedResult = await request(
      endpoint: EndpointName.character,
      body: {
        'character_ids': characterIdsJson,
        'server': server,
        'role_id': gameId
      },
      gameId: gameId,
      settings: settings,
      chinese: chinese,
      method: 'POST',
    );
    return CachedAPIResponse.fromCachedResult<UserCharacters>(
      cachedResult,
      UserCharacters.fromJson,
    );
  }

  Future<FullAbyssInfo> getSpiralAbyss({
    required int gameId,
  }) async {
    final server = recognizeServer(gameId);
    final chinese = isChineseServer(server);
    final settings = chinese ? settingsCn : settingsEu;
    final current = await request(
      endpoint: EndpointName.spiralAbyss,
      params: {'server': server, 'role_id': '$gameId', 'schedule_type': '1'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
    );
    final previous = await request(
      endpoint: EndpointName.spiralAbyss,
      params: {'server': server, 'role_id': '$gameId', 'schedule_type': '2'},
      gameId: gameId,
      settings: settings,
      chinese: chinese,
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
