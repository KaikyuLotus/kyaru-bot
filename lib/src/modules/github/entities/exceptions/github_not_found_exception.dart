class GithubNotFoundException implements Exception {
  String? description;

  GithubNotFoundException(this.description);

  @override
  String toString() => 'GithubNotFoundException: $description';
}
