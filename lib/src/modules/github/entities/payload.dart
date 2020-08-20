import 'github_commit.dart';

class Payload {
  String ref;
  String refType;
  String masterBranch;
  String description;
  String pusherType;
  String action;
  String head;

  List<GithubCommit> commits;

  Payload(
    this.ref,
    this.refType,
    this.masterBranch,
    this.description,
    this.pusherType,
    this.action,
    this.head,
    this.commits,
  );

  factory Payload.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Payload(
      json['ref'],
      json['ref_type'],
      json['master_branch'],
      json['description'],
      json['pusher_type'],
      json['action'],
      json['head'],
      GithubCommit.listFromJsonArray(json['commits']),
    );
  }
}
