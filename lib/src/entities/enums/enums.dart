import 'package:dart_telegram_bot/dart_telegram_bot.dart';

extension UpperEnums on EnumHelper {
  static String encodeUpper<T>(T menum) {
    return EnumHelper.encode(menum).toUpperCase();
  }
}

enum InstructionType { messageContent, command, regex, event, none }
enum InstructionEventType { userJoined, userLeft, kyaruJoined, none }
enum CommandType {
  image,
  video,
  sticker,
  text,
  photo,
  animation,
  unknown,
  document
}
