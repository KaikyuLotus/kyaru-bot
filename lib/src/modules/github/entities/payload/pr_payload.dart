import 'payload.dart';

class PullRequestPayload extends Payload {
  String action;
  int number;
  String htmlUrl;
  String title;
  int commits;
  int additions;
  int deletions;
  int changedFiles;

  PullRequestPayload(
    this.action,
    this.number,
    this.htmlUrl,
    this.title,
    this.commits,
    this.additions,
    this.deletions,
    this.changedFiles,
  );

  static PullRequestPayload fromJson(Map<String, dynamic> json) {
    var pullRequest = json['pull_request'];
    return PullRequestPayload(
      json['action'],
      json['number'],
      pullRequest['html_url'],
      pullRequest['title'],
      pullRequest['commits'],
      pullRequest['additions'],
      pullRequest['deletions'],
      pullRequest['changed_files'],
    );
  }
}
