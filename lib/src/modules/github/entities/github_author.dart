class GithubAuthor {
  String sha;
  String message;

  GithubAuthor(this.sha, this.message);

  factory GithubAuthor.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return GithubAuthor(
      json['sha'],
      json['message'],
    );
  }
}
