class _Enum<T> {
  final T _value;

  T get value => _value;

  const _Enum(this._value);

  @override
  String toString() => '$_value';

  String toJson() => '$this';
}

class GithubEventType extends _Enum<String> {
  static const commitCommentEvent = GithubEventType._('COMMIT_COMMENT_EVENT');
  static const createEvent = GithubEventType._('CREATE_EVENT');
  static const deleteEvent = GithubEventType._('DELETE_EVENT');
  static const forkEvent = GithubEventType._('FORK_EVENT');
  static const gollumEvent = GithubEventType._('GOLLUM_EVENT');
  static const issueCommentEvent = GithubEventType._('ISSUE_COMMENT_EVENT');
  static const issuesEvent = GithubEventType._('ISSUES_EVENT');
  static const memberEvent = GithubEventType._('MEMBER_EVENT');
  static const publicEvent = GithubEventType._('PUBLIC_EVENT');
  static const pullRequestEvent = GithubEventType._('PULL_REQUEST_EVENT');
  static const pullRequestReviewEvent =
      GithubEventType._('PULL_REQUEST_REVIEW_EVENT');
  static const pullRequestReviewCommentEvent =
      GithubEventType._('PULL_REQUEST_REVIEW_COMMENT_EVENT');
  static const pushEvent = GithubEventType._('PUSH_EVENT');
  static const releaseEvent = GithubEventType._('RELEASE_EVENT');
  static const sponsorshipEvent = GithubEventType._('SPONSORSHIP_EVENT');
  static const watchEvent = GithubEventType._('WATCH_EVENT');

  static const values = {
    'CommitCommentEvent': commitCommentEvent,
    'CreateEvent': createEvent,
    'DeleteEvent': deleteEvent,
    'ForkEvent': forkEvent,
    'GollumEvent': gollumEvent,
    'IssueCommentEvent': issueCommentEvent,
    'IssuesEvent': issuesEvent,
    'MemberEvent': memberEvent,
    'PublicEvent': publicEvent,
    'PullRequestEvent': pullRequestEvent,
    'PullRequestReviewEvent': pullRequestReviewEvent,
    'PullRequestReviewCommentEvent': pullRequestReviewCommentEvent,
    'PushEvent': pushEvent,
    'ReleaseEvent': releaseEvent,
    'SponsorshipEvent': sponsorshipEvent,
    'WatchEvent': watchEvent,
  };

  const GithubEventType._(String value) : super(value);

  static GithubEventType forValue(String value) =>
      GithubEventType.values[value]!;
}
