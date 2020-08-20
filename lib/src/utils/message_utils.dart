import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';

class MessageUtils {
  static CommandType getMessageCommandType(Message message) {
    if (message.sticker != null) {
      return CommandType.sticker;
    } else if (message.text != null) {
      return CommandType.text;
    } else if (message.photo != null && message.photo.isNotEmpty) {
      return CommandType.photo;
    } else if (message.video != null) {
      return CommandType.video;
    } else if (message.animation != null) {
      return CommandType.animation;
    } else if (message.document != null) {
      return CommandType.document;
    }
    return CommandType.unknown;
  }

  static String getMessageMediaFileId(Message message) {
    if (message.sticker != null) {
      return message.sticker.fileId;
    } else if (message.photo != null && message.photo.isNotEmpty) {
      return message.photo.last.fileId;
    } else if (message.video != null) {
      return message.video.fileId;
    } else if (message.animation != null) {
      return message.animation.fileId;
    } else if (message.document != null) {
      return message.document.fileId;
    }
    return null;
  }
}
