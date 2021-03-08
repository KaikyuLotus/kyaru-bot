import 'img_assets.dart';

class SelectedLegend {
  String? legendName;
  ImgAssets imgAssets;

  SelectedLegend(this.legendName, this.imgAssets);

  static SelectedLegend fromJson(Map<String, dynamic> json) {
    return SelectedLegend(
      json['LegendName'],
      ImgAssets.fromJson(json['ImgAssets']),
    );
  }
}
