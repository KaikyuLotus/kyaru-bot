class GithubHTTPException implements Exception {
  String description;

  int statusCode;

  GithubHTTPException(this.description, this.statusCode);

  @override
  String toString() => 'GithubHTTPException ($statusCode): $description';
}
