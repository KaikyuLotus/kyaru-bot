class GithubAsset {
  int? id;
  String? name;
  String? state;
  int? size;
  int? downloadCount;
  String? browserDownloadUrl;

  GithubAsset(
    this.id,
    this.name,
    this.state,
    this.size,
    this.downloadCount,
    this.browserDownloadUrl,
  );

  static GithubAsset fromJson(Map<String, dynamic> json) {
    return GithubAsset(
      json['id'],
      json['name'],
      json['state'],
      json['size'],
      json['download_count'],
      json['browser_download_url'],
    );
  }

  static List<GithubAsset> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => GithubAsset.fromJson(jsonArray[i]),
    );
  }
}
