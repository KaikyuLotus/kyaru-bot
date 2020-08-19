class GithubNotChangedException implements Exception {
  String description;

  int pollInterval;
  int rateLimit;
  int rateLimitRemaining;
  int rateLimitReset;

  GithubNotChangedException(
    this.description,
    this.pollInterval,
    this.rateLimit,
    this.rateLimitRemaining,
    this.rateLimitReset,
  );

  @override
  String toString() => 'GithubNotChangedException: $description';
}
