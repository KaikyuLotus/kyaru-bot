import 'package:kyaru_bot/kyaru.dart';

import '../entities/realtime_data.dart';
import 'global_data.dart';
import 'legends_data.dart';

class ApexData {
  String? error;

  GlobalData? global;
  RealtimeData? realtime;
  LegendsData? legends;

  ApexData(this.error, this.global, this.realtime, this.legends);

  static ApexData fromJson(Map<String, dynamic> json) {
    return ApexData(
      json['Error'],
      callIfNotNull(GlobalData.fromJson, json['global']),
      callIfNotNull(RealtimeData.fromJson, json['realtime']),
      callIfNotNull(LegendsData.fromJson, json['legends']),
    );
  }
}
