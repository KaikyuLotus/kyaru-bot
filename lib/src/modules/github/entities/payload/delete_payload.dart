import 'payload.dart';

class DeletePayload extends Payload {
  String ref;
  String refType;

  DeletePayload(
    this.ref,
    this.refType,
  );

  static DeletePayload fromJson(Map<String, dynamic> json) {
    return DeletePayload(
      json['ref'],
      json['ref_type'],
    );
  }
}
