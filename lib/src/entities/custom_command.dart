import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';

class CustomCommand {
  String? command;
  String? fileId;
  String? text;
  bool? quote;
  bool? quoteQuoted;
  CommandType commandType;

  CustomCommand(
    this.command,
    this.commandType, {
    this.quote,
    this.quoteQuoted,
    this.fileId,
    this.text,
  });

  static CustomCommand fromJson(Map<String, dynamic> json) {
    return CustomCommand(
      json['command'],
      EnumHelper.decode(CommandType.values, json['command_type']),
      quote: json['quote'] ?? false,
      quoteQuoted: json['quote_quoted'] ?? false,
      fileId: json['file_id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'command': command,
      'command_type': UpperEnums.encodeUpper(commandType),
      'quote': quote ?? false,
      'quote_quoted': quoteQuoted ?? false,
      'file_id': fileId,
      'text': text,
    };
  }
}
