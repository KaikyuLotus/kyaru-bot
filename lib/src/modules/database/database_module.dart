import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';

class DatabaseModule implements IModule {
  final _log = Logger('DatabaseModule');

  final Kyaru _kyaru;

  late List<ModuleFunction> _moduleFunctions;

  DatabaseModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(registerChat, 'Adds chats to the db', 'registerChat'),
      ModuleFunction(dbStats, 'Replies with DB statistics', 'dbStats'),
      ModuleFunction(cleanDb, 'Removes chats not available anymore', 'cleanDb'),
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

  Future cleanDb(Update update, _) async {
    var waitPerMsg = 1000 ~/ 25;
    var removed = 0;
    var errors = 0;
    for (var chat in _kyaru.brain.db.getChats()) {
      try {
        await _kyaru.brain.bot
            .sendChatAction(ChatID(chat.id), ChatAction.typing);
      } on APIException catch (e) {
        if (e.description.contains('Forbidden') ||
            e.description.contains('Bad Request')) {
          _kyaru.brain.db.removeChatData(chat.id);
          removed++;
        }
      } on Exception catch (e, s) {
        errors++;
        _log.severe('Could not send message to chat ${chat.id}: $e\n$s');
      }
      await Future.delayed(Duration(milliseconds: waitPerMsg));
    }
    _kyaru.reply(update, 'Removed $removed chats with $errors errors, master.');
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
