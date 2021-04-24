import 'github_commit.dart';
import 'github_release.dart';

class Payload {
  String? ref;
  String? refType;
  String? masterBranch;
  String? description;
  String? pusherType;
  String? action;
  String? head;
  int? number;
  List<GithubCommit>? commits;
  GithubRelease? release;

  Payload(
    this.ref,
    this.refType,
    this.masterBranch,
    this.description,
    this.pusherType,
    this.action,
    this.head,
    this.number,
    this.commits,
    this.release,
  );

  static Payload fromJson(Map<String, dynamic> json) {
    return Payload(
      json['ref'],
      json['ref_type'],
      json['master_branch'],
      json['description'],
      json['pusher_type'],
      json['action'],
      json['head'],
      json['number'],
      GithubCommit.listFromJsonArray(json['commits'] ?? []),
      GithubRelease.fromJson(json['release'] ?? <String, dynamic>{}),
    );
  }
}
