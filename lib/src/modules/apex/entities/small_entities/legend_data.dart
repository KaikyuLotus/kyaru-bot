class LegendData {
  String? name;
  int? value;
  String? key;

  LegendData(this.name, this.value, this.key);

  static LegendData fromJson(Map<String, dynamic> json) {
    return LegendData(
      json['name'],
      json['value'],
      json['key'],
    );
  }

  static List<LegendData> listFromJsonArray(List<dynamic> jsonArray) {
    return List<LegendData>.generate(
      jsonArray.length,
      (i) => LegendData.fromJson(jsonArray[i]),
    );
  }
}
