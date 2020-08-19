import 'small_entities/selected_legend.dart';

class LegendsData {

  LegendsData(this.selected);

  factory LegendsData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return LegendsData(
      SelectedLegend.fromJson(json['selected'] as Map<String, dynamic>),
    );
  }

  SelectedLegend selected;

}
