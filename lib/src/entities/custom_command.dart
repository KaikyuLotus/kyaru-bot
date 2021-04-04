
import '../../kyaru.dart';

class CustomCommand {
  String? command;
  String? fileId;
  String? text;
  bool quote;
  bool quoteQuoted;
  CommandType commandType;

  CustomCommand(
    this.command,
    this.commandType, {
    this.quote = false,
    this.quoteQuoted = false,
    this.fileId,
    this.text,
  });

  static CustomCommand fromJson(Map<String, dynamic> json) {
    return CustomCommand(
      json['command'],
      CommandType.forValue(json['command_type']),
      quote: json['quote'] ?? false,
      quoteQuoted: json['quote_quoted'] ?? false,
      fileId: json['file_id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'command': command,
      'command_type': commandType.value,
      'quote': quote,
      'quote_quoted': quoteQuoted,
      'file_id': fileId,
      'text': text,
    };
  }
}
