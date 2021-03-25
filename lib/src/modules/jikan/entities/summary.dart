class Summary {
  int? malId;
  String? type;
  String? name;
  String? url;

  Summary(
    this.malId,
    this.type,
    this.name,
    this.url,
  );

  static Summary fromJson(Map<String, dynamic> json) {
    return Summary(
      json['mal_id'],
      json['type'],
      json['name'],
      json['url'],
    );
  }

  static List<Summary> listFromJsonArray(List<dynamic> jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Summary.fromJson(jsonArray[i]),
    );
  }
}
