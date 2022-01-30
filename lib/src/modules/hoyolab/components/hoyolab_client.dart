import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:kyaru_bot/src/entities/cache_system.dart';
import 'package:logging/logging.dart';

import '../../../../kyaru.dart';
import 'credentials_distributor.dart';

enum EndpointName {
  indexPage,
  character,
  spiralAbyss,
  elysianRealm,
  arena,
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
  final Kyaru _kyaru;
  late CredentialsDistributor _credDistrib;

  HoyolabClient(this._kyaru) {
    _credDistrib = CredentialsDistributor.withDatabase(_kyaru.brain.db);
  }

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

  Future<CachedResult> request({
    required EndpointName endpoint,
    required int gameId,
    required ServerSettings settings,
    Map<String, dynamic>? body,
    Map<String, String>? params,
    bool chinese = false,
    required userId,
    String method = 'GET',
  }) async {
    final key = '$endpoint|$gameId|${json.encode(body)}|${json.encode(params)}';
    return _cacheSys.cacheOutput(
      key: key,
      function: () async {
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

        final credentials = _credDistrib.forUser(userId, gameId, chinese);

        var token = credentials.token;
        var uid = credentials.uid;

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
}
