import '../entities/realtime_data.dart';
import 'global_data.dart';
import 'legends_data.dart';

class ApexData {
  ApexData(this.error, this.global, this.realtime, this.legends);

  factory ApexData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ApexData(
      json['Error'] as String,
      GlobalData.fromJson(json['global'] as Map<String, dynamic>),
      RealtimeData.fromJson(json['realtime'] as Map<String, dynamic>),
      LegendsData.fromJson(json['legends'] as Map<String, dynamic>),
    );
  }

  String error;

  GlobalData global;
  RealtimeData realtime;
  LegendsData legends;
}
