class Anime {
  final String id;
  final String url;
  final Map titles;
  final String canonicalTitle;
  final List? abbreviatedTitles;
  final String description;
  final String? averageRating;
  final String imageLink;
  final int? episodeCount;
  final DateTime? startDate;
  final DateTime? endDate;

  Anime(
    this.id,
    this.url,
    this.titles,
    this.canonicalTitle,
    this.abbreviatedTitles,
    this.description,
    this.averageRating,
    this.imageLink,
    this.episodeCount,
    this.startDate,
    this.endDate,
  );

  static Anime fromJson(Map<String, dynamic> json) {
    var attributes = json['attributes'];
    var slug = attributes['slug'];
    return Anime(
      json['id'],
      'https://kitsu.io/anime/$slug',
      attributes['titles'],
      attributes['canonicalTitle'],
      attributes['abbreviatedTitles'],
      attributes['description'],
      attributes['averageRating'],
      attributes['posterImage']['original'],
      attributes['episodeCount'],
      DateTime.tryParse(attributes['startDate'] ?? ''),
      DateTime.tryParse(attributes['endDate'] ?? ''),
    );
  }

  static List<Anime> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Anime.fromJson(jsonArray[i]),
    );
  }
}
