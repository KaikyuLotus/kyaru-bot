import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';
import 'entities/danbooru_client.dart';
import 'entities/post.dart';

class DanbooruModule implements IModule {
  final Kyaru _kyaru;
  final DanbooruClient danbooruClient = DanbooruClient();

  final slowDownChats = <int>[];

  List<ModuleFunction> _moduleFunctions;

  DanbooruModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(danbooru, 'Search images from danbooru', 'danbooru', core: true),
      ModuleFunction(danbooru, 'Search images from danbooru', 'dnb', core: true),
    ];
  }

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future danbooru(Update update, Instruction instruction) async {
    var args = update.message.text.split(' ');
    args.removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) return await randomPostAsync(update, instruction);

    var specifiedMode = args[0].toLowerCase();

    var modeMap = {'random': randomPostAsync, 'tags': randomFromTags};

    for (var mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return await modeMap[mode](update, instruction);
      }
    }

    return await _kyaru.reply(update, 'Specified mode not recognized');
  }

  Future randomFromTags(Update update, Instruction instruction) {
    return randomPostAsync(update, instruction, tags: update.message.text.split(' ')..removeAt(0)..removeAt(0));
  }

  Future randomPostAsync(Update update, Instruction instruction, {List<String> tags}) async {
    if (tags != null) {
      tags = List.from(tags.map((t) => t.toLowerCase()));
      if (tags.isEmpty) {
        return _kyaru.reply(update, 'You must specify at least a tag');
      } else if (tags.contains('loli') || tags.contains('shota') || tags.contains('toddlercon')) {
        return _kyaru.reply(update, "You've specified a forbidden tag:\nDanbooru censors loli/shota/toddlercon tags.");
      }
    }

    tags ??= [];

    var imagesCount = 1;
    if (tags.isNotEmpty) {
      var firstTagNum = int.tryParse(tags.first);
      if (firstTagNum != null) {
        tags.removeAt(0);
        imagesCount = firstTagNum;
      }
    }

    var hasRating = tags.any((e) => e.contains('rating:'));
    if (tags.length > 3 || (tags.length == 3 && !hasRating)) {
      return _kyaru.reply(update, 'You can specify up to two tags, sorry.');
    }

    if (imagesCount > 10) return _kyaru.reply(update, 'I\'m allowed to send 10 max posts at a time, try again.');

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message.chat)) {
      tags.removeWhere((t) => t.contains('rating'));
      tags.add('rating:s');
    }

    var sentMessage = await _kyaru.reply(update, 'Give me a second...');

    var randomPostList = await danbooruClient.getPosts(tags: tags, limit: 100);
    if (randomPostList.isEmpty) {
      return _kyaru.editMessageText(
        'No post found with the specified tags',
        chatId: ChatID(update.message.chat.id),
        messageId: sentMessage.messageId,
      );
    }

    var captionMaker = (Post post) {
      var tagText = post.tagString.split(' ').take(imagesCount > 3 ? 5 : 10).map((t) => '`$t`').join(' ');
      return '${tagText}\n\n[Post](https://danbooru.donmai.us/posts/${post.id}) - [File](${post.fileUrl})';
    };

    var compatiblePostList =
        List.from(randomPostList.where((p) => !['webm', 'gif'].contains(p.fileExt) && p.largeFileUrl != null));

    compatiblePostList.shuffle();

    var httpFiles = compatiblePostList
        .take(imagesCount)
        .map(
          (p) => InputMediaPhoto(
            type: 'photo',
            media: p.largeFileUrl,
            caption: captionMaker(p),
            parseMode: ParseMode.Markdown(),
          ),
        )
        .toList();

    if (httpFiles.isEmpty) {
      return _kyaru.editMessageText(
        'Telegram does not support .webm format\nTry again or with other tags.',
        chatId: ChatID(update.message.chat.id),
        messageId: sentMessage.messageId,
        parseMode: ParseMode.Markdown(),
      );
    }

    var mediaCount = httpFiles.length;

    var slowed = slowDownChats.contains(update.message.chat.id);
    if (slowed) {
      await _kyaru.editMessageText(
        "Please slow down...\nI'll send the media group in some seconds...",
        chatId: ChatID(update.message.chat.id),
        messageId: sentMessage.messageId,
        parseMode: ParseMode.Markdown(),
      );
    }

    await Future.doWhile(
      () async => Future.delayed(
        Duration(milliseconds: 100),
        () => slowDownChats.contains(update.message.chat.id),
      ),
    );

    if (mediaCount > 3) {
      await _kyaru.sendChatAction(ChatID(update.message.chat.id), ChatAction.UPLOAD_PHOTO);
    }
    slowDownChats.add(update.message.chat.id);
    try {
      await _kyaru.sendMediaGroup(
        ChatID(update.message.chat.id),
        httpFiles,
        replyToMessageId: update.message.chat.type != 'private' ? update.message.messageId : null,
      );
      print('Messages sent');
    } finally {
      print('Removing id from slowed chats');
      Future.delayed(Duration(seconds: mediaCount * 3), () => slowDownChats.remove(update.message.chat.id));
    }
  }
}
