import 'payload.dart';

class ReleasePayload extends Payload {
  String action;
  String htmlUrl;
  String tagName;
  String name;
  bool draft;
  bool prerelease;

  ReleasePayload(
    this.action,
    this.htmlUrl,
    this.tagName,
    this.name,
    this.draft,
    this.prerelease,
  );

  static ReleasePayload fromJson(Map<String, dynamic> json) {
    var release = json['release'];
    return ReleasePayload(
      json['action'],
      release['html_url'],
      release['tag_name'],
      release['name'],
      release['draft'],
      release['prerelease'],
    );
  }
}
