class GithubReview {
  final int? id;
  final String? state;
  final String? prUrl;
  final String? authorAssociation;
  final int? prNumber;
  final String? title;

  GithubReview(
    this.id,
    this.state,
    this.prUrl,
    this.authorAssociation,
    this.prNumber,
    this.title,
  );

  static GithubReview fromJson(
    Map<String, dynamic> jsonReview,
    Map<String, dynamic> jsonPR,
  ) {
    return GithubReview(
      jsonReview['id'],
      jsonReview['state'],
      jsonReview['html_url'],
      jsonReview['author_association'],
      jsonPR['number'],
      jsonPR['title'],
    );
  }
}
