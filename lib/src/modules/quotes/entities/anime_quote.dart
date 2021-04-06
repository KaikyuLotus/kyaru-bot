class AnimeQuote {
  String anime;
  String character;
  String quote;

  AnimeQuote(
    this.anime,
    this.character,
    this.quote,
  );

  static AnimeQuote fromJson(Map<String, dynamic> json) {
    return AnimeQuote(
      json['anime'],
      json['character'],
      json['quote'],
    );
  }
}
