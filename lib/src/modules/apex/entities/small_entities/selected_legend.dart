import 'img_assets.dart';

class SelectedLegend {
  SelectedLegend(this.legendName, this.imgAssets);

  factory SelectedLegend.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return SelectedLegend(
      json['LegendName'] as String,
      ImgAssets.fromJson(json['ImgAssets'] as Map<String, dynamic>),
    );
  }

  String legendName;
  ImgAssets imgAssets;
}
