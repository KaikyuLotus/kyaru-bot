import '../../../../kyaru.dart';
import '../entities/realtime_data.dart';
import 'global_data.dart';
import 'legends_data.dart';

class ApexException implements Exception {
  final String error;

  ApexException(this.error);
}

class ApexData {
  GlobalData? global;
  LegendsData? legends;
  RealtimeData? realtime;

  ApexData(this.global, this.realtime, this.legends);

  static ApexData fromJson(Map<String, dynamic> json) {
    if (json['Error'] != null) {
      throw ApexException(json['Error']);
    }
    return ApexData(
      callIfNotNull(GlobalData.fromJson, json['global']),
      callIfNotNull(RealtimeData.fromJson, json['realtime']),
      callIfNotNull(LegendsData.fromJson, json['legends']),
    );
  }
}
