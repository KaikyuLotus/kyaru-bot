class Anime {
  int? malId;
  String? url;
  String? imageUrl;
  String? title;
  bool? airing;
  String? synopsis;
  String? type;
  int? episodes;
  double? score;
  DateTime? startDate;
  DateTime? endDate;
  int? members;
  String? rated;

  Anime(
    this.malId,
    this.url,
    this.imageUrl,
    this.title,
    this.synopsis,
    this.type,
    this.episodes,
    this.score,
    this.startDate,
    this.endDate,
    this.members,
    this.rated, {
    this.airing,
  });

  static Anime fromJson(Map<String, dynamic> json) {
    return Anime(
      json['mal_id'],
      json['url'],
      json['image_url'],
      json['title'],
      json['synopsis'],
      json['type'],
      json['episodes'],
      json['score'],
      null,
      // json['start_date'], // TODO date
      null,
      // json['end_date'],
      json['members'],
      json['rated'],
      airing: json['airing'],
    );
  }

  static List<Anime> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Anime.fromJson(jsonArray[i]),
    );
  }
}
