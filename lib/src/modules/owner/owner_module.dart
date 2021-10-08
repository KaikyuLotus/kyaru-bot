import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';

class OwnerModule implements IModule {
  final _log = Logger('OwnerModule');

  final Kyaru _kyaru;

  late List<ModuleFunction> _moduleFunctions;

  OwnerModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        getModulesStatus,
        'Sends a message with the enabled/disabled modules',
        'modulesStatus',
      ),
      ModuleFunction(
        onNewGroup,
        'Sends the new group message',
        'onNewGroup',
      ),
      ModuleFunction(
        notifyNewGroup,
        'Notifies a new group to the owner',
        'notifyNewGroup',
      ),
      ModuleFunction(
        help,
        'Sends an help message',
        'help',
        core: true,
      ),
      ModuleFunction(
        start,
        'Sends the start message',
        'start',
        core: true,
      ),
      ModuleFunction(
        broadcast,
        'Sends the quoted message to the specified type of chats',
        'broadcast',
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future getModulesStatus(Update update, _) async {
    var modules = _kyaru.brain.modules;
    var mtext = modules
        .map((m) =>
            '*${m.runtimeType}*: ${m.isEnabled() ? 'enabled' : 'disabled'}')
        .join('\n- ');

    var message = '*Modules*\n\n- $mtext\n\nHealth check reports no issues.';
    await _kyaru.reply(update, message, parseMode: ParseMode.markdown);
  }

  Future onNewGroup(Update update, _) async {
    var newGroupMessage =
        'Hello everyone!\nI\'m Kyaru, an utility bot made mainly for groups.\n'
        'Use /help to get a list of what I can do for you!';
    await _kyaru.reply(update, newGroupMessage);
  }

  Future notifyNewGroup(Update update, _) async {
    var chat = update.message!.chat;
    var chatId = ChatID(update.message!.chat.id);
    try {
      var chatTitle = MarkdownUtils.escape(chat.title, v2: false);
      var ownerMsg = 'New group!\n*$chatTitle*'
          '\nID: ${chat.id}';

      if (update.message!.chat.username != null) {
        ownerMsg += '\nUsername: `@${chat.username}`';
      }

      var usersCount = await _kyaru.brain.bot.getChatMemberCount(chatId);
      ownerMsg += '\nMembers: *$usersCount*';
      var newChat = await _kyaru.brain.bot.getChat(chatId);

      if (newChat.description != null) {
        var description = MarkdownUtils.escape(newChat.description, v2: false);
        ownerMsg += '\nDescription:\n`$description`';
      }

      var bigFileId = newChat.photo?.bigFileId;
      if (bigFileId != null) {
        var file = await _kyaru.brain.bot.getFile(newChat.photo!.bigFileId);
        var bytes = await _kyaru.brain.bot.download(file.filePath!);
        await _kyaru.brain.bot.sendPhoto(
          _kyaru.brain.db.settings.ownerId,
          HttpFile.fromBytes('propic.jpg', bytes),
          caption: ownerMsg,
          parseMode: ParseMode.markdown,
        );
      } else {
        var chatTitle = MarkdownUtils.escape(
          update.message!.chat.title,
          v2: false,
        );
        var message = 'New group: `$chatTitle`\nID: `${chat.id}`';
        if (update.message!.chat.description != null) {
          var description = MarkdownUtils.escape(
            update.message!.chat.description,
            v2: false,
          );
          message += '\nDescription: `$description`';
        }
        await _kyaru.brain.bot.sendMessage(
          _kyaru.brain.db.settings.ownerId,
          message,
          parseMode: ParseMode.markdown,
        );
      }
    } catch (e, s) {
      _log.severe('Failed to notify new group', e, s);

      var chatTitle = MarkdownUtils.escape(
        update.message!.chat.title,
        v2: false,
      );
      await _kyaru.brain.bot.sendMessage(
        _kyaru.brain.db.settings.ownerId,
        'New group: `$chatTitle`\nID: `${chat.id}`',
        parseMode: ParseMode.markdown,
      );
    }
  }

  Future start(Update update, _) async {
    var firstName = MarkdownUtils.escape(
      update.message!.from!.firstName,
      v2: false,
    );
    var startMessage = 'Hi $firstName,\n\n'
        "I'm Kyaru, an utility bot made mainly for groups.\n\n"
        'If you want to know how I work or who made me use the /help command\n'
        'You can find my code [here](https://github.com/KaikyuLotus/kyaru-bot/tree/develop), make sure to leave a star!.\n'
        '\n'
        '\nMade with ❤️ by [Kaikyu](https://t.me/kaikyu)\n'
        'Please consider a donation:\n'
        '[Ko-fi](https://ko-fi.com/kaikyulotus)\n'
        'ETH address: ```0xaF3E8F09cB2d202e9284D6CcfF093D95A29Cef1F```';
    await _kyaru.reply(
      update,
      startMessage,
      parseMode: ParseMode.markdown,
      hidePreview: true,
    );
  }

  Future help(Update update, _) async {
    var firstName = MarkdownUtils.escape(
      update.message!.from!.firstName,
      v2: false,
    );
    var helpMessage = 'Hi $firstName,\n\n'
        "I'm Kyaru, an utility bot made mainly for groups.\n\n"
        "I'm still in a early beta phase, so I may have lots of errors"
        " and unexpected behaviours, you can report them to @KaikyuLotus.\n\n"
        'Join @KyaruNews to stay tuned with updates on new commands and bug fixes!\n\n'
        "You can find my code [here](https://github.com/KaikyuLotus/kyaru-bot/tree/develop).\n\n"
        "Here's my command list:\n"
        '/lol PlayerUsername\n*Returns some LoL stats*\n\n'
        '/lol PlayerUsername Number\n*Returns some LoL stats with the Nth match stats*\n\n'
        '/danbooru\n*Sends a random image from Danbooru*\n\n'
        '/danbooru tags tag\\_list\n*Sends a random image from Danbooru with the given tags*\n\n'
        '/yandere\n*Sends a random image from Yandere*\n\n'
        '/yandere tags tag\\_list\n*Sends a random image from Yandere with the given tags*\n\n'
        '/nsfw\n*Enables or disables NSFW content in other modules (disabled by default)*\n\n'
        '/command Command\n*Creates a custom command that sends the quoted message and works only for the current chat*\n\n'
        '/commands\n*Sends a list of the current set commands with the replies*\n\n'
        '/forget command n\n*Deletes a reply from the specified command where n is the number shown in /commands*\n\n'
        '/welcome\n*Sends the quoted message when an user joins the group*n\n\n'
        '/welcome list\n*Sends a list of current welcome messages*\n\n'
        "/welcome exec n\n*Send a welcome message based on 'n' which is the number shown in /welcome list*\n\n"
        "/welcome del n\n*Deletes a welcome message based on 'n' which is the number shown in /welcome list*\n"
        '\nMade with ❤️ by [Kaikyu](https://t.me/kaikyu)';

    await _kyaru.reply(
      update,
      helpMessage,
      parseMode: ParseMode.markdown,
      hidePreview: true,
    );
  }

  Future broadcast(Update update, _) async {
    var args = update.message?.text?.split(' ')?..removeAt(0);
    if (args == null || args.isEmpty) {
      return _kyaru.reply(
        update,
        '/broadcast requires an argument which'
        ' can be either "users" or "groups"',
      );
    }

    var type = args.first.toLowerCase();
    if (!['users', 'groups'].contains(type)) {
      return _kyaru.reply(
        update,
        'The argument can be either "users" or "groups"',
      );
    }

    if (update.message?.replyToMessage == null) {
      return _kyaru.reply(
        update,
        'Please quote the message to be delivered to the $type.',
      );
    }

    var waitPerMsg = 1000 ~/ 25;
    var errors = 0;
    var sent = 0;
    var chatId = ChatID(update.message!.chat.id);
    var messageId = update.message!.replyToMessage!.messageId;

    bool filterByType(c) => c.isPrivate == (type == 'users');
    for (var chat in _kyaru.brain.db.getChats().where(filterByType)) {
      try {
        await _kyaru.brain.bot.copyMessage(ChatID(chat.id), chatId, messageId);
        sent++;
      } catch (e, s) {
        errors++;
        _log.severe('Could not send message to chat ${chat.id}: $e\n$s');
      }
      await Future.delayed(Duration(milliseconds: waitPerMsg));
    }

    return _kyaru.reply(
      update,
      'Message broadcasted to $sent chats,'
      ' there where $errors errors.',
    );
  }
}
