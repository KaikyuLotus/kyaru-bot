import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';

class AdminUtils {
  static Future<bool> isAdmin(Kyaru kyaru, Chat chat, User user) async {
    if (chat.type == 'private') {
      return true;
    }
    var users = await kyaru.getChatAdministrators(ChatID(chat.id));
    return users.map((m) => m?.user?.id).contains(user.id);
  }

  static Future<bool> isNsfwAllowed(Kyaru kyaru, Chat chat) async {
    var chatData = kyaru.kyaruDB.getChatData(chat.id);
    return chatData == null || (await chatData).nsfw;
  }
}
