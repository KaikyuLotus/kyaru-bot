import 'img_assets.dart';
import 'legend_data.dart';

class Legend {
  String legendName;
  List<LegendData> data;
  ImgAssets imgAssets;

  Legend(this.legendName, this.data, this.imgAssets);

  factory Legend.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Legend(
      json['LegendName'],
      LegendData.listFromJsonArray(json['data']),
      ImgAssets.fromJson(json['ImgAssets']),
    );
  }

  static List<Legend> listFromJsonNamedMap(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return List<Legend>.generate(json.keys.length, (i) {
      final name = json.keys.elementAt(i);
      json[name]['LegendName'] = name;
      return Legend.fromJson(json[name]);
    });
  }
}
