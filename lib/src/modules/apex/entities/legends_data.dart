import 'small_entities/selected_legend.dart';

class LegendsData {
  LegendsData(this.selected);

  static LegendsData fromJson(Map<String, dynamic> json) {
    return LegendsData(
      SelectedLegend.fromJson(json['selected']),
    );
  }

  SelectedLegend selected;
}
