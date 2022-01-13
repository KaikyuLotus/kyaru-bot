import '../../../../kyaru.dart';
import '../../hoyolab/components/hoyolab_client.dart';

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

  // TODO
  Future<Map> getCharacters() async {
    var gameId = 123;
    var cachedResult = await request(
      endpoint: EndpointName.character,
      params: {'server': 'eur01', 'role_id': '$gameId'},
      gameId: gameId,
      settings: settingsEu,
    );

    return cachedResult.current;
  }
}
