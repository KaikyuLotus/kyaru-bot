import 'genre.dart';
import 'platform.dart';
import 'tag.dart';

class VideogameDetails {
  final int id;
  final String slug;
  final String name;
  final String nameOriginal;
  final String description;
  final List<Platform> platforms;
  final List<Genre> genres;
  final List<Tag> tags;

  VideogameDetails(
    this.id,
    this.slug,
    this.name,
    this.nameOriginal,
    this.description,
    this.platforms,
    this.genres,
    this.tags,
  );

  static VideogameDetails fromJson(Map<String, dynamic> json) {
    return VideogameDetails(
      json['id'],
      json['slug'],
      json['name'],
      json['name_original'],
      json['description'],
      Platform.listFromJsonArray(
          json['platforms'].map((platform) => platform['platform']).toList()),
      Genre.listFromJsonArray(json['genres']),
      Tag.listFromJsonArray(json['tags']),
    );
  }
}
