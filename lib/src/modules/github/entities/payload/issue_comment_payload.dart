import 'payload.dart';

class IssueCommentPayload extends Payload {
  String action;
  String htmlUrl;
  int number;
  String title;
  String body;

  IssueCommentPayload(
    this.action,
    this.htmlUrl,
    this.number,
    this.title,
    this.body,
  );

  static IssueCommentPayload fromJson(Map<String, dynamic> json) {
    var issue = json['issue'];
    var comment = json['comment'];
    return IssueCommentPayload(
      json['action'],
      issue['html_url'],
      issue['number'],
      issue['title'],
      comment['body'],
    );
  }
}
