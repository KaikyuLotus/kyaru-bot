import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../kyaru.dart';

class Kyaru {
  final _log = Logger('Kyaru');

  late final KyaruBrain brain;

  Kyaru({
    required FutureOr Function(Kyaru) onReady,
  }) {
    var db = KyaruDB();
    var bot = Bot(
      token: db.settings.token,
      onStartFailed: onStartFailed,
      onReady: (b) async => await onReady.call(this),
    );
    brain = KyaruBrain(database: db, bot: bot);
    brain.bot.onUpdate(_updatesHandler);
    brain.bot.errorHandler = onError;
    brain.bot.onCommand('add_owner_cmd', addOwnerCommand);
    brain.bot.onCommand('alias', addCommandAlias);
  }

  Future onStartFailed(Bot bot, Object e, StackTrace st) async {
    _log.shout('Start failed', e, st);
  }

  void start({
    bool clean = true,
    List<UpdateType>? allowedUpdates,
  }) {
    brain.bot.allowedUpdates = allowedUpdates;
    brain.bot.start(clean: clean);
  }

  void useModules(List<IModule> modules) => brain.useModules(modules);

  Future _updatesHandler(Bot bot, Update update) async {
    try {
      if (update.callbackQuery != null) return;
      if (update.inlineQuery != null) return;
      if (update.message?.forwardDate != null) return;
      if (update.message?.chat.type == 'channel') return;

      if (await brain.readEvents(update)) return;

      if (update.message?.text == null || update.message?.from == null) return;

      await brain.readMessage(update);
    } catch (e, s) {
      _log.shout('My life is a failure', e, s);
      await onError(brain.bot, update, e, s);
    }
  }

  int? getReplyMessageId(
    Update update, {
    bool quote = false,
    bool quoteQuoted = false,
  }) {
    return quoteQuoted
        ? update.message!.replyToMessage!.messageId
        : quote
            ? update.message!.messageId
            : null;
  }

  Future noticeOwnerError(Object e, StackTrace s) async {
    return noticeOwner('$e\n$s');
  }

  Future noticeOwner(String message) async {
    await brain.bot.sendMessage(brain.db.settings.ownerId, message);
  }

  Future onError(Bot bot, Update update, Object e, StackTrace s) async {
    _log.severe('Kyaru machine broke', e, s);
    await noticeOwnerError(e, s);
    _log.severe('Update ID was: ${update.updateId}');
    return reply(
      update,
      'Sorry, an error has occurred...\n'
      'My owner has been already informed.\n'
      'Thanks for your patience.',
    );
  }

  Future<Message> reply(
    Update update,
    String message, {
    ParseMode? parseMode,
    bool quote = false,
    bool quoteQuoted = false,
    bool hidePreview = false,
    ReplyMarkup? replyMarkup,
  }) {
    return brain.bot.sendMessage(
      ChatID(update.message!.chat.id),
      message,
      parseMode: parseMode,
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
      disableWebPagePreview: hidePreview,
      replyMarkup: replyMarkup,
    );
  }

  Future replySticker(
    Update update,
    String fileId, {
    ParseMode? parseMode,
    bool quote = false,
    bool quoteQuoted = false,
  }) async {
    return brain.bot.sendSticker(
      ChatID(update.message!.chat.id),
      HttpFile.fromToken(fileId),
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
    );
  }

  Future replyPhoto(
    Update update,
    HttpFile httpFile, {
    String? caption,
    ParseMode? parseMode,
    bool quote = false,
    bool quoteQuoted = false,
  }) {
    return brain.bot.sendPhoto(
      ChatID(update.message!.chat.id),
      httpFile,
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
      caption: caption,
      parseMode: parseMode,
    );
  }

  Future replyVideo(
    Update update,
    HttpFile httpFile, {
    ParseMode? parseMode,
    String? caption,
    bool quote = false,
    bool quoteQuoted = false,
  }) {
    return brain.bot.sendVideo(
      ChatID(update.message!.chat.id),
      httpFile,
      caption: caption,
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
      parseMode: parseMode,
    );
  }

  Future replyAnimation(
    Update update,
    HttpFile httpFile, {
    String? caption,
    bool quote = false,
    bool quoteQuoted = false,
    ParseMode? parseMode,
  }) {
    return brain.bot.sendAnimation(
      ChatID(update.message!.chat.id),
      httpFile,
      caption: caption,
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
      parseMode: parseMode,
    );
  }

  Future replyDocument(
    Update update,
    HttpFile httpFile, {
    String? caption,
    bool quote = false,
    bool quoteQuoted = false,
    ParseMode? parseMode,
  }) {
    return brain.bot.sendDocument(
      ChatID(update.message!.chat.id),
      httpFile,
      caption: caption,
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
      parseMode: parseMode,
    );
  }

  Future deleteMessage(Update update, Message message) {
    return brain.bot.deleteMessage(
      ChatID(update.message!.chat.id),
      message.messageId,
    );
  }

  Future editMessage(Update update, Message message, String text) {
    return brain.bot.editMessageText(
      text,
      chatId: ChatID(update.message!.chat.id),
      messageId: message.messageId,
    );
  }

  Future addOwnerCommand(Bot bot, Update update) async {
    if (update.message?.chat == null) return;
    if (update.message?.from?.id != brain.db.settings.ownerId.chatId) return;

    var args = update.message?.text?.split(' ')?..removeAt(0);

    if (args == null || args.isEmpty) {
      return reply(
        update,
        'Please specify a custom command as first argument',
      );
    }

    var command = args.first;

    // TODO is ugly
    var ownerOnly = true;
    if (command != args.last) {
      var bString = args.last.toLowerCase();
      if (!['true', 'false'].contains(bString)) {
        return reply(update, 'Invalid boolean value');
      }
      ownerOnly = bString == 'true';
    }

    var commands = brain.modules
        .map((c) => c.moduleFunctions.map((f) => f.name).toList())
        .reduce((v, e) => v + e);

    if (!commands.contains(command)) {
      return reply(
        update,
        "I couldn't find any function matching '$command' "
        "registered in any module",
      );
    }

    var customInstruction = Instruction(
      ownerOnly: ownerOnly,
      instructionType: InstructionType.command,
      requireQuote: false,
      volatile: false,
      chatId: 0,
      command: CustomCommand(
        commandType: CommandType.unknown,
        command: command,
      ),
      function: command,
      instructionEventType: InstructionEventType.none,
      regex: null,
    );

    brain.db.addCustomInstruction(customInstruction);
    return reply(update, 'Done, master.');
  }

  Future addCommandAlias(Bot bot, Update update) async {
    if (update.message?.chat == null) return;
    if (update.message?.from?.id != brain.db.settings.ownerId.chatId) return;

    var args = update.message?.text?.split(' ')?..removeAt(0);

    if (args == null || args.isEmpty) {
      return reply(update, 'Usage: /alias command, type, alias');
    }

    var params = args.join(' ').split(',').map((e) => e.trim());
    if (params.length != 3) {
      return reply(update, 'Usage: /alias command, type, alias');
    }

    var command = params.elementAt(0);
    var typeString = params.elementAt(1).toUpperCase();
    var aliasString = params.elementAt(2);

    if (!['REGEX', 'COMMAND'].contains(typeString)) {
      return reply(
        update,
        "Type $typeString cannot be an alias or does not exist",
      );
    }

    var type = InstructionType.forValue(typeString);

    if (command == aliasString) {
      return reply(update, "Can't add an alias equal to the command itself");
    }

    var instructions = brain.db.getAllInstructions(command);
    var matchingInstructions =
        instructions.where((e) => e.command?.command == command);
    if (matchingInstructions.isEmpty) {
      return reply(update, 'Command "$command" not found...');
    }
    var instruction = matchingInstructions.first;

    for (var alias in instruction.aliases) {
      if (alias.instructionType == type) {
        if ((alias.instructionType == InstructionType.regex &&
                alias.regex == aliasString) ||
            alias.command?.command == aliasString) {
          return reply(update, 'That alias is already present');
        }
      }
    }

    var newAlias = InstructionAlias(
      instructionType: type,
      regex: type == InstructionType.regex ? aliasString : null,
      command: type == InstructionType.command
          ? CustomCommand(
              commandType: CommandType.unknown,
              command: aliasString,
            )
          : null,
    );

    instruction.aliases.add(newAlias);
    if (brain.db.updateInstruction(instruction)) {
      return reply(
        update,
        'Created an alias of type $typeString '
        'for command $command: "$aliasString"',
      );
    } else {
      return reply(
        update,
        'Failed to save the alias...',
      );
    }
  }
}
