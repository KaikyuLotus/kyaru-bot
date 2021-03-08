class GithubForbiddenException implements Exception {
  String? description;

  int? rateLimit;
  int? rateLimitRemaining;
  int? rateLimitReset;

  GithubForbiddenException(
    this.description,
    this.rateLimit,
    this.rateLimitRemaining,
    this.rateLimitReset,
  );

  @override
  String toString() => 'GithubForbiddenException: $description';
}
