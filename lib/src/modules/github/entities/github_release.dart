import 'github_asset.dart';

class GithubRelease {
  int? id;
  String? tagName;
  String? name;
  List<GithubAsset>? assets;
  String? body;
  bool? draft;
  bool? prerelease;

  GithubRelease(
    this.id,
    this.tagName,
    this.name,
    this.assets,
    this.body, {
    required this.draft,
    required this.prerelease,
  });

  static GithubRelease fromJson(Map<String, dynamic> json) {
    return GithubRelease(
      json['id'],
      json['tag_name'],
      json['name'],
      GithubAsset.listFromJsonArray(json['assets'] ?? []),
      json['body'],
      draft: json['draft'],
      prerelease: json['prerelease'],
    );
  }
}
