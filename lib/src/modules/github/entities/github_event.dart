import 'package:jiffy/jiffy.dart';

import 'actor.dart';
import 'github_event_type.dart';
import 'payload.dart';
import 'repo.dart';

class GithubEvent {
  String? id;
  GithubEventType type;
  Actor actor;
  Repo repo;
  Payload? payload;
  bool? public;
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

  static GithubEvent fromJson(Map<String, dynamic> json) {
    return GithubEvent(
      json['id'],
      GithubEventType.forValue(json['type']),
      Actor.fromJson(json['actor']),
      Repo.fromJson(json['repo']),
      Payload.fromJson(json['payload']),
      Jiffy(json['created_at']).dateTime,
      public: json['public'],
    );
  }

  static List<GithubEvent> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => GithubEvent.fromJson(jsonArray[i]),
    );
  }

  @override
  String toString() {
    switch (type) {
      case GithubEventType.createEvent:
        var what = 'something';
        if (payload?.refType == 'repository') {
          what = 'this repository';
        } else if (payload?.refType == 'branch') {
          what = 'branch ${payload?.ref}';
        }
        return '${actor.displayLogin} created $what';

      case GithubEventType.pushEvent:
        var newSha7 = payload?.head!.substring(0, 7);
        var branch = payload?.ref!.split('/').last;
        var message = payload?.commits!.last.message;
        return '${actor.displayLogin} made a commit ($newSha7) '
            'to ${repo.name} on branch $branch:\n$message';

      case GithubEventType.watchEvent:
        return '${actor.displayLogin} ${payload?.action}'
            ' watching the repository';

      case GithubEventType.forkEvent:
        return '${actor.displayLogin} forked ${repo.name}';

      case GithubEventType.pullRequestEvent:
        if (payload?.action == 'opened' || payload?.action == 'closed') {
          return '${actor.displayLogin} ${payload?.action} '
              'PR#${payload?.number}';
        } else {
          return '${actor.displayLogin} made an action: ${payload?.action} '
              'on PR#${payload?.number}';
        }

      case GithubEventType.releaseEvent:
        var release = payload!.release!;
        var releaseType = release.prerelease! ? 'prerelease' : 'release';
        var body = '';
        var assetsMessage = '';
        if (release.body!.isNotEmpty) {
          body = '\n\n${release.body}';
        }

        if (release.assets!.isNotEmpty) {
          var assets = release.assets!.map(
              (a) => '- ${a.name} ${(a.size! / 1048576).toStringAsFixed(2)}MB');
          assetsMessage = '\n\nAssets\n${assets.join('\n')}';
        }

        return '${actor.displayLogin} created a new $releaseType '
            '(${release.name})$body$assetsMessage';

      case GithubEventType.pullRequestReviewEvent:
        return '${actor.displayLogin} (${payload!.review!.authorAssociation}) '
            '${payload!.review!.state} PR#${payload!.review!.prNumber}';

      case GithubEventType.deleteEvent:
        return '${actor.displayLogin} deleted ${payload!.refType}'
            '${payload!.ref} on ${repo.name}';

      default:
        return 'Unknown action on ${repo.name}';
    }
  }
}
