import 'small_entities/selected_legend.dart';

class LegendsData {

  SelectedLegend selected;

  LegendsData(this.selected);

  static LegendsData fromJson(Map<String, dynamic> json) {
    return LegendsData(
      SelectedLegend.fromJson(json['selected']),
    );
  }
}
