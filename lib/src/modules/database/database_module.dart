import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';

class DatabaseModule implements IModule {
  final Kyaru _kyaru;

  late List<ModuleFunction> _moduleFunctions;

  DatabaseModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(registerChat, 'Adds chats to the db', 'registerChat'),
      ModuleFunction(dbStats, 'Replies with DB statistics', 'dbStats')
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future dbStats(Update update, _) async {
    var chatCounts = _kyaru.brain.db.getChatCounts();

    var private = chatCounts['private'];
    var groups = chatCounts['groups'];

    var msg = 'Database stats:\n'
        'Private chats: $private\n'
        'Group chats: $groups\n'
        '....bop!';

    await _kyaru.reply(update, msg);
  }

  Future registerChat(Update update, _) async {
    // TODO improve this once Kyaru is migrated to MongoDB
    var chatData = _kyaru.brain.db.getChatData(update.message!.chat.id);
    chatData ??= ChatData(
      update.message!.chat.id,
      nsfw: false,
      isPrivate: update.message!.chat.type == 'private',
    );
    _kyaru.brain.db.updateChatData(chatData);
  }
}
