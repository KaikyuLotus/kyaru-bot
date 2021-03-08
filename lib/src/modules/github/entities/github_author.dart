class GithubAuthor {
  String? sha;
  String? message;

  GithubAuthor(this.sha, this.message);

  static GithubAuthor fromJson(Map<String, dynamic> json) {
    return GithubAuthor(
      json['sha'],
      json['message'],
    );
  }
}
