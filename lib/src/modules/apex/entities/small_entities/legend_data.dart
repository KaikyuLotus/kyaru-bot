class LegendData {
  String name;
  int value;
  String key;

  LegendData(this.name, this.value, this.key);

  factory LegendData.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return LegendData(
      json['name'],
      json['value'],
      json['key'],
    );
  }

  static List<LegendData> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) {
      return <LegendData>[];
    }
    return List<LegendData>.generate(jsonArray.length, (i) => LegendData.fromJson(jsonArray[i]));
  }
}
