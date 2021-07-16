class Constellation {
  final String name;
  final String effect;

  Constellation(this.name, this.effect);

  static Constellation fromJson(Map<String, dynamic> json) {
    return Constellation(json['name'], json['effect']);
  }
}

class Constellations {
  final String character;
  final List<Constellation> constellations;

  Constellations(this.character, this.constellations);

  static Constellations fromJson(Map<String, dynamic> json) {
    var constellations = <Constellation>[];
    for (var c = 1; json['c$c'] != null; c++) {
      constellations.add(Constellation.fromJson(json['c$c']));
    }
    return Constellations(json['name'], constellations);
  }
}
