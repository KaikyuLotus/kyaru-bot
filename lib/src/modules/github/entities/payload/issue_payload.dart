import 'payload.dart';

class IssuePayload extends Payload {
  String action;
  String htmlUrl;
  int number;
  String title;

  IssuePayload(
    this.action,
    this.htmlUrl,
    this.number,
    this.title,
  );

  static IssuePayload fromJson(Map<String, dynamic> json) {
    var issue = json['issue'];
    return IssuePayload(
      json['action'],
      issue['html_url'],
      issue['number'],
      issue['title'],
    );
  }
}
