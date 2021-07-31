import 'package:jiffy/jiffy.dart';

import 'actor.dart';
import 'github_event_type.dart';
import 'payload/payloads.dart';
import 'repo.dart';

class GithubEvent {
  String id;
  GithubEventType type;
  Actor actor;
  Repo repo;
  Payload? payload;
  bool public;
  DateTime createdAt;

  GithubEvent(
    this.id,
    this.type,
    this.actor,
    this.repo,
    this.payload,
    this.public,
    this.createdAt,
  );

  static GithubEvent fromJson(Map<String, dynamic> json) {
    var type = GithubEventType.forValue(json['type']);
    return GithubEvent(
      json['id'],
      type,
      Actor.fromJson(json['actor']),
      Repo.fromJson(json['repo']),
      payloadType(type, json['payload']),
      json['public'],
      Jiffy(json['created_at']).dateTime,
    );
  }

  static List<GithubEvent> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => GithubEvent.fromJson(jsonArray[i]),
    );
  }

  static Payload? payloadType(
    GithubEventType type,
    Map<String, dynamic> payload,
  ) {
    var types = {
      GithubEventType.createEvent: CreatePayload.fromJson,
      GithubEventType.deleteEvent: DeletePayload.fromJson,
      GithubEventType.issueCommentEvent: IssueCommentPayload.fromJson,
      GithubEventType.issuesEvent: IssuePayload.fromJson,
      GithubEventType.pullRequestEvent: PullRequestPayload.fromJson,
      GithubEventType.pushEvent: PushPayload.fromJson,
      GithubEventType.releaseEvent: ReleasePayload.fromJson,
      GithubEventType.watchEvent: WatchPayload.fromJson,
    };
    if (types.containsKey(type)) {
      return types[type]!(payload);
    }
    return null;
  }

  @override
  String toString() {
    switch (type) {
      case GithubEventType.createEvent:
        var createPl = payload as CreatePayload;
        var what = {
          'repository': 'this repository',
          'branch': 'branch ${createPl.ref}',
          'tag': 'a new tag (${createPl.ref})',
        };
        return '${actor.displayLogin} created '
            '${what[createPl.refType] ?? 'something'}';

      case GithubEventType.pushEvent:
        var pushPl = payload as PushPayload;
        var newSha7 = pushPl.head.substring(0, 7);
        var branch = pushPl.ref.split('/').last;
        var message = pushPl.commits.last.message;
        return '${actor.displayLogin} made a commit ($newSha7) '
            'to ${repo.name} on branch $branch:\n$message';

      case GithubEventType.watchEvent:
        return '${actor.displayLogin} ${(payload as WatchPayload).action}'
            ' watching the repository';

      case GithubEventType.forkEvent:
        return '${actor.displayLogin} forked ${repo.name}';

      case GithubEventType.pullRequestEvent:
        var prPl = payload as PullRequestPayload;
        if (prPl.action == 'opened' || prPl.action == 'closed') {
          var commits = '${prPl.commits} commits';
          var files = '${prPl.changedFiles} changed files';
          if (prPl.commits == 1) {
            commits = '${prPl.commits} commit';
          }
          if (prPl.commits == 1) {
            files = '${prPl.changedFiles} changed file';
          }
          return '${actor.displayLogin} ${prPl.action} '
              'PR#${prPl.number} (${prPl.title}) with $commits and $files '
              '(${prPl.additions} additions, ${prPl.deletions} deletions)';
        } else {
          return '${actor.displayLogin} made an action: ${prPl.action} '
              'on PR#${prPl.number}';
        }

      case GithubEventType.releaseEvent:
        var releasePl = payload as ReleasePayload;
        var releaseType = releasePl.prerelease ? 'prerelease' : 'release';
        return '${actor.displayLogin} created a new $releaseType '
            '(${releasePl.name})';

      case GithubEventType.deleteEvent:
        var deletePl = payload as DeletePayload;
        return '${actor.displayLogin} deleted ${deletePl.refType} '
            '${deletePl.ref} on ${repo.name}';

      case GithubEventType.issuesEvent:
        var issuePl = payload as IssuePayload;
        return '${actor.displayLogin} ${issuePl.action} '
            'issue #${issuePl.number} (${issuePl.title})';

      case GithubEventType.issueCommentEvent:
        var issueCommentPl = payload as IssueCommentPayload;
        return '${actor.displayLogin} commented on '
            'issue #${issueCommentPl.number} (${issueCommentPl.title})';

      default:
        return 'Unknown action on ${repo.name}';
    }
  }
}
