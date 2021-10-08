class Talent {
  final String name;
  final String info;
  final List<String>? labels;
  final Map<String, dynamic>? parameters;

  Talent(
    this.name,
    this.info,
    this.labels,
    this.parameters,
  );

  static Talent fromJson(Map<String, dynamic> json) {
    return Talent(
      json['name'],
      json['info'],
      json['attributes']?['labels'].cast<String>(),
      json['attributes']?['parameters'],
    );
  }

  static List<Talent> listFromJsonArray(Map<String, dynamic> jsonArray) {
    var talents = <Talent>[];
    jsonArray.remove('name');
    jsonArray.remove('costs');
    jsonArray.remove('images');
    jsonArray.forEach((_, value) {
      talents.add(Talent.fromJson(value));
    });
    return talents;
  }
}
