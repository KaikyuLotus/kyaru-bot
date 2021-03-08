class Actor {
  int? id;
  String? login;
  String? displayLogin;
  String? gravatarId;
  String? url;
  String? avatarUrl;

  Actor(
    this.id,
    this.login,
    this.displayLogin,
    this.gravatarId,
    this.url,
    this.avatarUrl,
  );

  static Actor fromJson(Map<String, dynamic> json) {
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
