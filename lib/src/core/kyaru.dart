import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';

class Kyaru extends KyaruBrain {
  Kyaru(KyaruDB db, String token) : super(db, token) {
    onUpdate(_updatesHandler);
  }

  Future<void> _updatesHandler(Update update) async {
    try {
      if (update.callbackQuery != null) {
        // await handleCallbackQuery(update);
        return;
      }

      if (update.inlineQuery != null) {
        // await handleInlineQuery(update);
        return;
      }

      // TODO decide what to do with forwarded messages
      if (update?.message?.forwardDate != null) {
        return;
      }

      // TODO maybe work in channels too?
      if (update?.message?.chat?.type == 'channel') {
        return;
      } // Ignore channels

      // TODO owner stuff
      // if (isOwner) {
      //   await checkDialogUpdate(update);
      // }

      if (await readEvents(update)) {
        return;
      } // Was an event

      if (update.message?.text == null || update.message?.from == null) {
        return;
      }

      await readMessage(update);
    } on Exception catch (e, s) {
      print('My life is a failure: $e:\n$s');
    }
  }

  int getReplyMessageId(Update update, {bool quote = false, bool quoteQuoted = false}) {
    return quoteQuoted ? update.message.replyToMessage.messageId : quote ? update.message.messageId : null;
  }

  Future<void> noticeOwner(Update update, Exception e, StackTrace s) async {
    print('$e\n$s');
    await sendMessage(ChatID((await kyaruDB.getSettings()).ownerId), '$e\n$s').catchError((e, s) => print('$e\n$s'));
  }

  void onError(Update update, Exception e, StackTrace s) {
    reply(update, 'Sorry, an error has occourred...\nMy owner has been already informed.\nThanks for your patience.')
        .catchError((e, s) => print('$e\n$s'));
    noticeOwner(update, e, s);
  }

  Future<Message> reply(
    Update update,
    String message, {
    ParseMode parseMode,
    bool quote = false,
    bool quoteQuoted = false,
    bool hidePreview = false,
    ReplyMarkup replyMarkup,
  }) async {
    return await sendMessage(ChatID(update.message.chat.id), message,
        parseMode: parseMode,
        replyToMessageId: getReplyMessageId(update, quote: quote, quoteQuoted: quoteQuoted),
        disableWebPagePreview: hidePreview,
        replyMarkup: replyMarkup);
  }

  Future<void> replySticker(
    Update update,
    String fileId, {
    ParseMode parseMode,
    bool quote = false,
    bool quoteQuoted = false,
  }) async {
    await sendSticker(
      ChatID(update.message.chat.id),
      HttpFile.fromToken(fileId),
      replyToMessageId: getReplyMessageId(
        update,
        quote: quote,
        quoteQuoted: quoteQuoted,
      ),
    );
  }

  Future<void> replyPhoto(
    Update update,
    HttpFile httpFile, {
    String caption,
    ParseMode parseMode,
    bool quote = false,
    bool quoteQuoted = false,
  }) async {
    await sendPhoto(
      ChatID(update.message.chat.id),
      httpFile,
      replyToMessageId: getReplyMessageId(update, quote: quote, quoteQuoted: quoteQuoted),
      caption: caption,
      parseMode: parseMode,
    );
  }

  Future<void> replyVideo(
    Update update,
    HttpFile httpFile, {
    ParseMode parseMode,
    String caption,
    bool quote = false,
    bool quoteQuoted = false,
  }) async {
    await sendVideo(
      ChatID(update.message.chat.id),
      httpFile,
      caption: caption,
      replyToMessageId: getReplyMessageId(update, quote: quote, quoteQuoted: quoteQuoted),
      parseMode: parseMode,
    );
  }

  Future<void> replyAnimation(
    Update update,
    HttpFile httpFile, {
    String caption,
    bool quote = false,
    bool quoteQuoted = false,
    ParseMode parseMode,
  }) async {
    await sendAnimation(
      ChatID(update.message.chat.id),
      httpFile,
      caption: caption,
      replyToMessageId: getReplyMessageId(update, quote: quote, quoteQuoted: quoteQuoted),
      parseMode: parseMode,
    );
  }

  Future<void> replyDocument(
    Update update,
    HttpFile httpFile, {
    String caption,
    bool quote = false,
    bool quoteQuoted = false,
    ParseMode parseMode,
  }) async {
    await sendDocument(
      ChatID(update.message.chat.id),
      httpFile,
      caption: caption,
      replyToMessageId: getReplyMessageId(update, quote: quote, quoteQuoted: quoteQuoted),
      parseMode: parseMode,
    );
  }
}
