import 'img_assets.dart';
import 'legend_data.dart';

class Legend {
  Legend(this.legendName, this.data, this.imgAssets);

  factory Legend.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Legend(
      json['LegendName'] as String,
      LegendData.listFromJsonArray(json['data'] as List<dynamic>),
      ImgAssets.fromJson(json['ImgAssets'] as Map<String, dynamic>),
    );
  }

  String legendName;
  List<LegendData> data;
  ImgAssets imgAssets;

  static List<Legend> listFromJsonNamedMap(Map<String, dynamic> json) {
    if (json == null) return null;
    return List<Legend>.generate(json.keys.length, (int i) {
      final String name = json.keys.elementAt(i);
      json[name]['LegendName'] = name;
      return Legend.fromJson(json[name] as Map<String, dynamic>);
    });
  }
}
