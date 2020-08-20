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

  final _client = Client();

  Future<Response> _get<T>(Uri uri, {Map<String, String> headers}) {
    return _client.get(uri, headers: headers).timeout(Duration(seconds: 120));
  }

  Future<GithubEventsResponse> events(String user, String repo, {String etag}) async {
    return _get(
      Uri.https(apiBaseUrl, '/networks/$user/$repo/events'),
      headers: {'If-None-Match': '$etag'},
    ).then((httpResponse) {
      // TODO remove redundant int.tryParse ...

      if (httpResponse.statusCode == 403) {
        throw GithubForbiddenException(
          json.decode(httpResponse.body)['message'],
          int.tryParse(httpResponse.headers['x-ratelimit-limit']),
          int.tryParse(httpResponse.headers['x-ratelimit-remaining']),
          int.tryParse(httpResponse.headers['x-ratelimit-reset']),
        );
      }
      if (httpResponse.statusCode == 404) {
        throw GithubNotFoundException(json.decode(httpResponse.body)['message']);
      }
      if (httpResponse.statusCode == 304) {
        throw GithubNotChangedException(
          repo,
          int.tryParse(httpResponse.headers['x-poll-interval']),
          int.tryParse(httpResponse.headers['x-ratelimit-limit']),
          int.tryParse(httpResponse.headers['x-ratelimit-remaining']),
          int.tryParse(httpResponse.headers['x-ratelimit-reset']),
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
        int.tryParse(httpResponse.headers['x-poll-interval']),
        int.tryParse(httpResponse.headers['x-ratelimit-limit']),
        int.tryParse(httpResponse.headers['x-ratelimit-remaining']),
        int.tryParse(httpResponse.headers['x-ratelimit-reset']),
      );
    });
  }
}
