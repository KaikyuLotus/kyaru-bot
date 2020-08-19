import 'github_event.dart';

class GithubEventsResponse {
  List<GithubEvent> events;
  String etag;

  int pollInterval;
  int rateLimit;
  int rateLimitRemaining;
  int rateLimitReset;

  GithubEventsResponse(
    this.events,
    this.etag,
    this.pollInterval,
    this.rateLimit,
    this.rateLimitRemaining,
    this.rateLimitReset,
  );
}
