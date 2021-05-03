class User {
  final String name;
  final String? realName;
  final String url;
  final String imageUrl;
  final int playcount;
  final int playlists;
  final String country;

  User(
    this.name,
    this.realName,
    this.url,
    this.imageUrl,
    this.playcount,
    this.playlists,
    this.country,
  );

  static User fromJson(Map<String, dynamic> json) {
    return User(
      json['name'],
      json['realname'],
      json['url'],
      json['image'].last['#text'],
      int.parse(json['playcount']),
      int.parse(json['playlists']),
      json['country'],
    );
  }
}
