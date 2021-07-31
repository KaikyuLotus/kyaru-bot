import 'payload.dart';
import '../github_commit.dart';

class PushPayload extends Payload {
  String ref;
  String head;
  List<GithubCommit> commits;

  PushPayload(
    this.ref,
    this.head,
    this.commits,
  );

  static PushPayload fromJson(Map<String, dynamic> json) {
    return PushPayload(
      json['ref'],
      json['head'],
      GithubCommit.listFromJsonArray(json['commits']),
    );
  }
}
