import 'dart:convert';

import 'package:http/http.dart';

import 'exceptions/github_forbidden_exception.dart';
import 'exceptions/github_http_exception.dart';
import 'exceptions/github_not_changed_exception.dart';
import 'exceptions/github_not_found_exception.dart';
import 'github_event.dart';
import 'github_events_response.dart';

class GithubClient {
  final String apiBaseUrl = 'api.github.com';
  final String? token;

  final _client = Client();

  GithubClient(this.token);

  Future<Response> _get<T>(Uri uri, {Map<String, String>? headers}) {
    return _client.get(uri, headers: headers).timeout(Duration(seconds: 120));
  }

  Future<GithubEventsResponse> events(String? user, String? repo,
      {String? etag}) async {
    return _get(
      Uri.https(apiBaseUrl, '/networks/$user/$repo/events'),
      headers: {
        'If-None-Match': etag ?? '',
        'Authorization': 'Basic $token',
      },
    ).then((httpResponse) {
      int? getIntHeader(String name) {
        return int.tryParse(httpResponse.headers[name] ?? '');
      }

      var pollInterval = getIntHeader('x-poll-interval');
      var ratelimitLimit = getIntHeader('x-ratelimit-limit');
      var ratelimitRemaining = getIntHeader('x-ratelimit-remaining');
      var ratelimitReset = getIntHeader('x-ratelimit-reset');

      if (httpResponse.statusCode == 403) {
        throw GithubForbiddenException(
          json.decode(httpResponse.body)['message'],
          ratelimitLimit,
          ratelimitRemaining,
          ratelimitReset,
        );
      }
      if (httpResponse.statusCode == 404) {
        throw GithubNotFoundException(
          json.decode(httpResponse.body)['message'],
        );
      }
      if (httpResponse.statusCode == 304) {
        throw GithubNotChangedException(
          repo,
          pollInterval,
          ratelimitLimit,
          ratelimitRemaining,
          ratelimitReset,
        );
      }
      if (httpResponse.statusCode != 200) {
        throw GithubHTTPException(
          json.decode(httpResponse.body)['message'],
          httpResponse.statusCode,
        );
      }

      return GithubEventsResponse(
        GithubEvent.listFromJsonArray(json.decode(httpResponse.body)),
        httpResponse.headers['etag'],
        pollInterval,
        ratelimitLimit,
        ratelimitRemaining,
        ratelimitReset,
      );
    });
  }
}
