import '../entities/realtime_data.dart';
import 'global_data.dart';
import 'legends_data.dart';

class ApexData {
  String error;

  GlobalData global;
  RealtimeData realtime;
  LegendsData legends;

  ApexData(this.error, this.global, this.realtime, this.legends);

  factory ApexData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ApexData(
      json['Error'],
      GlobalData.fromJson(json['global']),
      RealtimeData.fromJson(json['realtime']),
      LegendsData.fromJson(json['legends']),
    );
  }
}
