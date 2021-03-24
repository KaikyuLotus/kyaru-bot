import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../kyaru.dart';

class Kyaru {
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
  }

  Future onStartFailed(Bot bot, Object e, StackTrace st) async {
    print('Start failed: $e,\n$st');
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

      // TODO decide what to do with forwarded messages
      if (update.message?.forwardDate != null) return;

      // TODO maybe work in channels too?
      if (update.message?.chat.type == 'channel') return;

      // TODO owner stuff here

      if (await brain.readEvents(update)) return;

      if (update.message?.text == null || update.message?.from == null) return;

      await brain.readMessage(update);
    } catch (e, s) {
      print('My life is a failure: $e:\n$s');
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

  Future noticeOwner(Update? update, Object e, StackTrace s) async {
    await brain.bot.sendMessage(ChatID(brain.db.settings.ownerId), '$e\n$s');
  }

  Future onError(Bot bot, Update? updateNull, Object e, StackTrace s) async {
    print('Kyaru machine broke\n$e\ns');
    var update = updateNull;
    await noticeOwner(update, e, s);
    if (update == null) {
      print('Error outside of an update, something went wrong');
      return;
    }
    print('Update ID was: ${update.updateId}');
    await reply(
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
}
