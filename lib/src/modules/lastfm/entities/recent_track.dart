class RecentTrack {
  String title;
  String artist;
  String album;
  String imageUrl;
  bool nowPlaying;

  RecentTrack({
    required this.title,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.nowPlaying,
  });

  static RecentTrack fromJson(Map<String, dynamic> json) {
    return RecentTrack(
      title: json['name'],
      artist: json['artist']['#text'],
      album: json['album']['#text'],
      imageUrl: json['image'].last['#text'],
      nowPlaying: json.containsKey('@attr'),
    );
  }
}
