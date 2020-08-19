class LegendData {
  LegendData(this.name, this.value, this.key);

  factory LegendData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return LegendData(
      json['name'] as String,
      json['value'] as int,
      json['key'] as String,
    );
  }

  static List<LegendData> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return <LegendData>[];
    return List<LegendData>.generate(
      jsonArray.length,
      (int i) => LegendData.fromJson(jsonArray[i] as Map<String, dynamic>),
    );
  }

  String name;
  int value;
  String key;
}
