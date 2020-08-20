class Actor {
  int id;
  String login;
  String displayLogin;
  String gravatarId;
  String url;
  String avatarUrl;

  Actor(
    this.id,
    this.login,
    this.displayLogin,
    this.gravatarId,
    this.url,
    this.avatarUrl,
  );

  factory Actor.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Actor(
      json['id'],
      json['login'],
      json['display_login'],
      json['gravatar_id'],
      json['url'],
      json['avatar_url'],
    );
  }
}
