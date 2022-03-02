class Objective {
  bool first;
  int kills;

  Objective(
    this.first,
    this.kills,
  );

  static Objective fromJson(Map<String, dynamic> json) {
    return Objective(
      json['first'],
      json['kills'],
    );
  }
}
