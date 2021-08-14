import 'payload.dart';

class CreatePayload extends Payload {
  String? ref;
  String? refType;

  CreatePayload(
    this.ref,
    this.refType,
  );

  static CreatePayload fromJson(Map<String, dynamic> json) {
    return CreatePayload(
      json['ref'],
      json['ref_type'],
    );
  }
}
