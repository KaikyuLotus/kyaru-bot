import 'package:jiffy/jiffy.dart';

import '../../../../kyaru.dart';
import 'actor.dart';
import 'github_event_type.dart';
import 'payload.dart';
import 'repo.dart';

class GithubEvent {
  String id;
  GithubEventType type;
  Actor actor;
  Repo repo;
  Payload payload;
  bool public;
  DateTime createdAt;

  GithubEvent(
    this.id,
    this.type,
    this.actor,
    this.repo,
    this.payload,
    this.createdAt, {
    this.public,
  });

  factory GithubEvent.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return GithubEvent(
      json['id'],
      EnumHelper.get(GithubEventType.values, json['type']),
      Actor.fromJson(json['actor']),
      Repo.fromJson(json['repo']),
      Payload.fromJson(json['payload']),
      Jiffy(json['created_at']).dateTime,
      public: json['public'],
    );
  }

  static List<GithubEvent> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) {
      return null;
    }
    return List.generate(jsonArray.length, (i) => GithubEvent.fromJson(jsonArray[i]));
  }

  @override
  String toString() {
    switch (type) {
      case GithubEventType.createEvent:
        var what = 'something';
        if (payload.refType == 'repository') {
          what = 'this repository';
        } else if (payload.refType == 'branch') {
          what = 'branch ${payload.ref}';
        }
        return '${actor.displayLogin} created $what';
      case GithubEventType.pushEvent:
        var newSha7 = payload.head.substring(0, 7);
        var branch = payload.ref.split('/').last;
        var message = payload.commits.last.message;
        return '${actor.displayLogin} made a commit ($newSha7) to ${repo.name} on branch $branch:\n$message';
      case GithubEventType.watchEvent:
        return '${actor.displayLogin} ${payload.action} watching the repository';
    }
    return 'unknown';
  }
}
