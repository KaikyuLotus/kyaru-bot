import 'img_assets.dart';

class SelectedLegend {
  String legendName;
  ImgAssets imgAssets;

  SelectedLegend(this.legendName, this.imgAssets);

  factory SelectedLegend.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return SelectedLegend(
      json['LegendName'],
      ImgAssets.fromJson(json['ImgAssets']),
    );
  }
}
