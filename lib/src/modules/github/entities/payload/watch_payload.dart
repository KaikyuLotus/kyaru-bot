import 'payload.dart';

class WatchPayload extends Payload {
  String action;

  WatchPayload(
    this.action,
  );

  static WatchPayload fromJson(Map<String, dynamic> json) {
    return WatchPayload(json['action']);
  }
}
