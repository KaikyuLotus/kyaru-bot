import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:kyaru_bot/kyaru.dart';
import 'package:kyaru_bot/src/entities/cache_system.dart';
import 'package:logging/logging.dart';

import '../entities/genshin_entities.dart';
import 'credentials_distributor.dart';

enum EndpointName {
  indexPage,
  character,
  spiralAbyss,
}

class UnknownServerForGameIdException implements Exception {
  final int uid;

  UnknownServerForGameIdException(this.uid);

  @override
  String toString() => 'UnknownServerForGameIdException: $uid';
}

class ServerSettings {
  final String salt;
  final String host;
  final String rpcVer;
  final String clientType;
  final String lang;
  final Map<EndpointName, String> endpoints;

  const ServerSettings({
    required this.salt,
    required this.host,
    required this.rpcVer,
    required this.clientType,
    required this.lang,
    required this.endpoints,
  });
}

const _timeout = Duration(seconds: 10);

const _servers = <int, String>{
  1: 'cn_gf01',
  5: 'cn_qd01',
  6: 'os_usa',
  7: 'os_euro',
  8: 'os_asia',
  9: 'os_cht',
};

const _settingsEu = ServerSettings(
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

const _settingsCn = ServerSettings(
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

class HoyolabAPIException implements Exception {
  final String message;
  final int statusCode;

  HoyolabAPIException(this.message, this.statusCode);

  @override
  String toString() => 'HoyolabAPIException ($statusCode): $message';
}

extension on Request {
  Request clone() {
    return Request(method, url)
      ..body = body
      ..bodyFields = bodyFields
      ..bodyBytes = bodyBytes
      ..contentLength = contentLength
      ..encoding = encoding
      ..headers.addAll(headers)
      ..persistentConnection = persistentConnection
      ..followRedirects = followRedirects
      ..maxRedirects = maxRedirects;
  }
}

class HoyolabClient {
  final _log = Logger('HoyolabClient');
  final _client = Client();
  final _cacheSys = CacheSystem(systemKey: 'hoyolab-api');

  String _generateDsTokenEu(String salt) {
    final t = DateTime.now().millisecondsSinceEpoch ~/ 1000; // current seconds
    final r = randomString(6); // 6 random chars
    final h = md5.convert(utf8.encode('salt=$salt&t=$t&r=$r')).toString();
    return '$t,$r,$h';
  }

  String _generateDsTokenCn(
    salt, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
  }) {
    final t = DateTime.now().millisecondsSinceEpoch ~/ 1000; // current seconds
    final r = '${rnd(100001, 200000)}';
    final b = body != null ? json.encode(body) : "";
    var q = '';
    if (params != null) {
      final query = Uri(queryParameters: params).query.split('&')..sort();
      q = query.join('&');
    }
    final c = md5.convert(utf8.encode('salt=$salt&t=$t&r=$r&b=$b&q=$q'));
    return '$t,$r,$c';
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

  bool isChineseServer(String server) => server.startsWith(RegExp(r'(cn|1|5)'));

  Future<StreamedResponse> _requestWithRetry(
    Request request, {
    int retries = 3,
    int retry = 1,
  }) async {
    try {
      return await _client.send(request).timeout(_timeout);
    } catch (_) {
      if (retry == retries) {
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 1));
      return _requestWithRetry(request.clone(), retry: retry + 1);
    }
  }

  Future<CachedResult> _request({
    required EndpointName endpoint,
    required int gameId,
    required String server,
    required int uid,
    required String token,
    Map<String, dynamic>? body,
    Map<String, String>? params,
    String method = 'GET',
  }) async {
    final key = '$endpoint|$gameId|${json.encode(body)}|${json.encode(params)}';
    return _cacheSys.cacheOutput(
      key: key,
      function: () async {
        final chinese = isChineseServer(server);
        final settings = chinese ? _settingsCn : _settingsEu;

        String ds;
        if (chinese) {
          ds = _generateDsTokenCn(settings.salt, params: params, body: body);
        } else {
          ds = _generateDsTokenEu(settings.salt);
        }
        final endpointString = settings.endpoints[endpoint]!;
        final request = Request(
          method,
          Uri.https(settings.host, endpointString, params),
        );
        if (body != null) {
          request.body = json.encode(body);
        }
        request.headers.addAll(
          <String, String>{
            "Cookie": "ltoken=$token; ltuid=$uid;",
            "DS": ds,
            'Accept': 'application/json',
            'X-Requested-With': 'com.mihoyo.hyperion',
            'Origin': 'https://webstatic.mihoyo.com',
            'Referer': 'https://webstatic.mihoyo.com/app/'
                'community-game-records/index.html?v=6',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; '
                'Win64; x64) miHoYoBBS/2.11.1',
            'Accept-Encoding': 'gzip, deflate',
            'Accept-Language': 'zh-CN,en-US;q=0.8',
            "x-rpc-client_type": settings.clientType,
            "x-rpc-language": settings.lang,
            "x-rpc-app_version": settings.rpcVer,
          },
        );

        _log.info('Sending request to ${settings.host} endp: $endpointString');
        final response = await _requestWithRetry(request);
        if (response.statusCode != 200) {
          throw HoyolabAPIException(
            await response.stream.bytesToString(),
            response.statusCode,
          );
        }
        final jsonString = await response.stream.bytesToString();
        return json.decode(jsonString);
      },
    );
  }

  Future<CachedAPIResponse<UserInfo>> getUserData({
    required int gameId,
    required HoyolabCredentials credentials,
  }) async {
    final server = recognizeServer(gameId);
    var cachedResult = await _request(
      endpoint: EndpointName.indexPage,
      params: {'server': server, 'role_id': '$gameId'},
      gameId: gameId,
      uid: credentials.uid,
      token: credentials.token,
      server: server,
    );
    return CachedAPIResponse.fromCachedResult<UserInfo>(
      cachedResult,
      UserInfo.fromJson,
    );
  }

  Future<CachedAPIResponse<UserCharacters>> getCharacters({
    required int gameId,
    required HoyolabCredentials credentials,
    required List<int> characterIdsJson,
  }) async {
    final server = recognizeServer(gameId);
    var cachedResult = await _request(
      endpoint: EndpointName.character,
      body: {
        'character_ids': characterIdsJson,
        'server': server,
        'role_id': gameId
      },
      gameId: gameId,
      uid: credentials.uid,
      token: credentials.token,
      server: server,
      method: 'POST',
    );
    return CachedAPIResponse.fromCachedResult<UserCharacters>(
      cachedResult,
      UserCharacters.fromJson,
    );
  }

  Future<FullAbyssInfo> getSpiralAbyss({
    required int gameId,
    required HoyolabCredentials credentials,
  }) async {
    final server = recognizeServer(gameId);
    final current = await _request(
      endpoint: EndpointName.spiralAbyss,
      params: {'server': server, 'role_id': '$gameId', 'schedule_type': '1'},
      gameId: gameId,
      uid: credentials.uid,
      token: credentials.token,
      server: server,
    );
    final previous = await _request(
      endpoint: EndpointName.spiralAbyss,
      params: {'server': server, 'role_id': '$gameId', 'schedule_type': '2'},
      gameId: gameId,
      uid: credentials.uid,
      token: credentials.token,
      server: server,
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
