import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';

class OwnerModule implements IModule {
  final Kyaru _kyaru;

  List<ModuleFunction> _moduleFunctions;

  OwnerModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(getModulesStatus, 'Sends a message with the enabled/disabled modules', 'modulesStatus'),
      ModuleFunction(onNewGroup, 'Sends the new group message', 'onNewGroup'),
      ModuleFunction(notifyNewGroup, 'Notifies a new group to the owner', 'notifyNewGroup'),
      ModuleFunction(help, 'Sends an help message', 'help', core: true),
      ModuleFunction(start, 'Sends the start message', 'start', core: true),
    ];
  }

  @override
  Future<void> init() async {}

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future getModulesStatus(Update update, Instruction instruction) async {
    var modules = _kyaru.modules;
    var mtext = modules.map((m) => '*${m.runtimeType}*: ${m.isEnabled() ? 'enabled' : 'disabled'}').join('\n- ');

    var message = '*Modules*\n\n- $mtext\n\nHealth check reports no issues.';
    await _kyaru.reply(update, message, parseMode: ParseMode.Markdown());
  }

  Future onNewGroup(Update update, Instruction instruction) async {
    var newGroupMessage =
        'Hello everyone!\nI\'m Kyaru, an utility bot made mainly for groups.\nUse /help to get a list of what I can do for you!';
    await _kyaru.reply(update, newGroupMessage);
  }

  Future notifyNewGroup(Update update, Instruction instruction) async {
    var chat = update.message.chat;
    var chatId = ChatID(update.message.chat.id);
    try {
      var ownerMsg = 'New group!\n*${chat.title}*'
          '\nID: ${chat.id}';

      if (update.message.chat.username != null) {
        ownerMsg += '\nUsername: `@${chat.username}`';
      }

      var usersCount = await _kyaru.getChatMembersCount(chatId);
      ownerMsg += '\nMembers: *$usersCount*';
      var newChat = await _kyaru.getChat(chatId);

      if (newChat.description != null) {
        ownerMsg += '\nDescription:\n`${newChat.description}`';
      }

      var bigFileId = newChat?.photo?.bigFileId;
      if (bigFileId != null) {
        var file = await _kyaru.getFile(newChat.photo.bigFileId);
        var bytes = await _kyaru.download(file.filePath);
        await _kyaru.sendPhoto(
          ChatID((await _kyaru.kyaruDB.getSettings()).ownerId),
          HttpFile.fromBytes('propic.jpg', bytes),
          caption: ownerMsg,
          parseMode: ParseMode.Markdown(),
        );
      } else {
        var message = 'New group: `${update.message.chat.title}`\nID: `${chat.id}`';
        if (update.message.chat.description != null) {
          message += '\nDescription: `${update.message.chat.description}`';
        }
        await _kyaru.sendMessage(ChatID((await _kyaru.kyaruDB.getSettings()).ownerId), message,
            parseMode: ParseMode.Markdown());
      }
    } on Exception catch (e, s) {
      print('$e\n$s');

      await _kyaru.sendMessage(
        ChatID((await _kyaru.kyaruDB.getSettings()).ownerId),
        'New group: `${update.message.chat.title}`\nID: `${chat.id}`',
        parseMode: ParseMode.Markdown(),
      );
    }
  }

  Future start(Update update, Instruction instruction) async {
    var startMessage = 'Hi ${update.message.from.firstName},\n\n'
        "I'm Kyaru, an utility bot made mainly for groups.\n\n"
        'If you want to know how I work or who made me use the /help command\n\n'
        '\nMade with ❤️ by [Kaikyu](https://t.me/kaikyu)';
    await _kyaru.reply(update, startMessage, parseMode: ParseMode.Markdown(), hidePreview: true);
  }

  Future help(Update update, Instruction instruction) async {
    var helpMessage = 'Hi ${update.message.from.firstName},\n\n'
        "I'm Kyaru, an utility bot made mainly for groups.\n\n"
        "I'm still in a early beta phase, so I may have lots of errors and unexpected behaviours, you can report them to @KaikyuLotus.\n\n"
        'Follow my development on my [Trello](https://trello.com/b/BJgZ2PBs/kyaru-roadmap) board\n\n'
        'Take a look at @KyaruLinks and join @KyaruNews to keep you updated on new commands and bug fixes!\n\n'
        "Currently I'm closed source, but all my libraries are open source:\n"
        '[Dart Telegram Bot (Telegram API Wrapper)](https://github.com/KaikyuDev/dart-telegram-bot)\n'
        '[Dart Mongo Lite (file-based MongoDB)](https://github.com/KaikyuDev/dart_mongo_lite)\n\n'
        "Here's my command list:\n\n"
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

    await _kyaru.reply(update, helpMessage, parseMode: ParseMode.Markdown(), hidePreview: true);
  }
}
