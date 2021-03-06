import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/user.dart';

extension on KyaruDB {
  static const _sinoAliceDataCollection = 'sinoalice_data';

  List<UserSinoAliceData> getUsersSinoAliceData() {
    return database[_sinoAliceDataCollection].findAs(
      UserSinoAliceData.fromJson,
    );
  }

  UserSinoAliceData? getUserSinoAliceData(int userId) {
    return database[_sinoAliceDataCollection].findOneAs(
      UserSinoAliceData.fromJson,
      filter: {'user_id': userId},
    );
  }

  void updateUserSinoAliceData(UserSinoAliceData data) {
    database[_sinoAliceDataCollection].update(
      {'user_id': data.userId},
      data.toJson(),
      true,
    );
  }

  bool deleteUserSinoAliceData(int userId) {
    return database[_sinoAliceDataCollection].delete(
      {'user_id': userId},
    );
  }
}

class SinoAliceModule implements IModule {
  final Kyaru _kyaru;

  late List<ModuleFunction> _moduleFunctions;

  SinoAliceModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        sindel,
        'Remove your SiNOALICE user ID from my database',
        'sindel',
        core: true,
      ),
      ModuleFunction(
        sinid,
        'Send your SiNOALICE user ID',
        'sinid',
        core: true,
      ),
      ModuleFunction(
        sinlist,
        'Send this group\'s SiNOALICE user IDs',
        'sinlist',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future sindel(Update update, _) async {
    var deleted = _kyaru.brain.db.deleteUserSinoAliceData(
      update.message!.from!.id,
    );
    if (!deleted) {
      return _kyaru.reply(
        update,
        'I don\'t even know who you are',
        quote: true,
      );
    }
    return _kyaru.reply(update, 'ID removed from my database', quote: true);
  }

  Future sinlist(Update update, _) async {
    var usersData = _kyaru.brain.db.getUsersSinoAliceData();
    if (usersData.isEmpty) {
      return _kyaru.reply(update, 'No SiNOALICE ID registered in this chat');
    }
    var okUserData = <String?, ChatMember>{};
    for (var userData in usersData) {
      try {
        okUserData[userData.gameId] = await _kyaru.brain.bot.getChatMember(
          ChatID(update.message!.chat.id),
          userData.userId,
        );
      } on APIException {
        // Pass
      }
    }
    final buffer = StringBuffer();
    for (var entry in okUserData.entries) {
      var nameLink = MarkdownUtils.generateUrl(
        MarkdownUtils.escape(entry.value.user.firstName)!,
        'tg://user?id=${entry.value.user.id}',
      );
      buffer.write('\n$nameLink: `${entry.key}`');
    }
    return _kyaru.reply(
      update,
      buffer.toString(),
      parseMode: ParseMode.markdownV2,
    );
  }

  Future sinid(Update update, _) {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isNotEmpty) {
      // We have an id registration
      // 575220441
      var id = args[0];
      if (id.length != 9) {
        return _kyaru.reply(update, 'I think that this is not a valid user ID');
      }

      var intId = int.tryParse(id);
      if (intId == null) {
        return _kyaru.reply(update, 'I think that this is not a valid user ID');
      }

      _kyaru.brain.db.updateUserSinoAliceData(
        UserSinoAliceData(update.message!.from!.id, id),
      );
      return _kyaru.reply(
        update,
        "I've registered your game ID\nJust type /sinid to show it",
        quote: true,
      );
    }

    var quote = update.message!.replyToMessage != null;
    var firstName = quote
        ? update.message!.replyToMessage!.from!.firstName
        : update.message!.from!.firstName;
    var userId = update.message!.from!.id;
    var nameLink = MarkdownUtils.generateUrl(firstName, 'tg://user?id=$userId');
    if (quote) {
      userId = update.message!.replyToMessage!.from!.id;
    }

    var normalError = 'Please register your ID with /sinid 0000000 first';
    var quoteError = 'Sorry, this user has no ID';

    var userData = _kyaru.brain.db.getUserSinoAliceData(userId);
    if (userData == null) {
      return _kyaru.reply(
        update,
        quote ? quoteError : normalError,
        quote: true,
      );
    }

    return _kyaru.reply(
      update,
      '$nameLink ID: `${userData.gameId}`',
      parseMode: ParseMode.markdown,
      quote: true,
    );
  }
}
