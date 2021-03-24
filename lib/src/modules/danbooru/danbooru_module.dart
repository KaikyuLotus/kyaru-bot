import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/danbooru_client.dart';
import 'entities/post.dart';

class DanbooruModule implements IModule {
  final Kyaru _kyaru;
  final DanbooruClient danbooruClient = DanbooruClient();

  final List<int> slowDownChats = <int>[];

  List<ModuleFunction>? _moduleFunctions;

  DanbooruModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        danbooru,
        'Search images from danbooru',
        'danbooru',
        core: true,
      ),
      ModuleFunction(
        danbooru,
        'Search images from danbooru',
        'dnb',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction>? get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future danbooru(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) {
      return await randomPostAsync(update, null);
    }

    var specifiedMode = args[0].toLowerCase();

    var modeMap = {'random': randomPostAsync, 'tags': randomFromTags};

    for (var mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return await modeMap[mode]!(update, null);
      }
    }

    return await _kyaru.reply(update, 'Specified mode not recognized');
  }

  Future randomFromTags(Update update, _) {
    return randomPostAsync(
      update,
      _,
      tags: update.message!.text!.split(' ')..removeAt(0)..removeAt(0),
    );
  }

  Future randomPostAsync(Update update, _, {List<String>? tags}) async {
    var elaboratedTags = tags ?? [];
    elaboratedTags = List.from(elaboratedTags.map((t) => t.toLowerCase()));
    if (elaboratedTags.isEmpty) {
      return _kyaru.reply(update, 'You must specify at least a tag [e:2]');
    } else if (elaboratedTags.contains('loli') ||
        elaboratedTags.contains('shota') ||
        elaboratedTags.contains('toddlercon')) {
      return _kyaru.reply(
        update,
        "You've specified a forbidden tag:\n"
        'Danbooru censors loli/shota/toddler tags.',
      );
    }

    var imagesCount = 1;
    if (elaboratedTags.isNotEmpty) {
      var firstTagNum = int.tryParse(elaboratedTags.first);
      if (firstTagNum != null) {
        elaboratedTags.removeAt(0);
        imagesCount = firstTagNum;
      }
    }

    var hasRating = elaboratedTags.any((e) => e.contains('rating:'));
    if (elaboratedTags.length > 3 ||
        (elaboratedTags.length == 3 && !hasRating)) {
      return _kyaru.reply(update, 'You can specify up to two tags, sorry.');
    }

    if (imagesCount > 10) {
      return _kyaru.reply(
        update,
        'I\'m allowed to send 10 max posts at a time, try again.',
      );
    }

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message!.chat)) {
      elaboratedTags.removeWhere((t) => t.contains('rating'));
      // ignore: cascade_invocations
      elaboratedTags.add('rating:s');
    }

    var sentMessage = await _kyaru.reply(update, 'Give me a second...');

    var randomPostList = await danbooruClient.getPosts(
      tags: elaboratedTags,
      limit: 100,
    );
    if (randomPostList.isEmpty) {
      return _kyaru.brain.bot.editMessageText(
        'No post found with the specified tags',
        chatId: ChatID(update.message!.chat.id),
        messageId: sentMessage.messageId,
      );
    }

    String captionMaker(Post post) {
      var tagText = post.tagString!
          .split(' ')
          .take(imagesCount > 3 ? 5 : 10)
          .map((t) => '`$t`')
          .join(' ');
      return '$tagText\n\n[Post](https://danbooru.donmai.us/posts/${post.id}) '
          '- [File](${post.fileUrl})';
    }

    var compatiblePostList = List.from(
      randomPostList.where(
        (p) => !['webm', 'gif'].contains(p.fileExt) && p.largeFileUrl != null,
      ),
    )..shuffle();

    var httpFiles = compatiblePostList
        .take(imagesCount)
        .map(
          (p) => InputMediaPhoto(
            type: 'photo',
            media: p.largeFileUrl,
            caption: captionMaker(p),
            parseMode: ParseMode.MARKDOWN,
          ),
        )
        .toList();

    if (httpFiles.isEmpty) {
      return _kyaru.brain.bot.editMessageText(
        'Telegram does not support .webm format\nTry again or with other tags.',
        chatId: ChatID(update.message!.chat.id),
        messageId: sentMessage.messageId,
        parseMode: ParseMode.MARKDOWN,
      );
    }

    var mediaCount = httpFiles.length;

    var slowed = slowDownChats.contains(update.message!.chat.id);
    if (slowed) {
      await _kyaru.brain.bot.editMessageText(
        "Please slow down...\nI'll send the media group in some seconds...",
        chatId: ChatID(update.message!.chat.id),
        messageId: sentMessage.messageId,
        parseMode: ParseMode.MARKDOWN,
      );
    }

    await Future.doWhile(
      () async => Future.delayed(
        Duration(milliseconds: 100),
        () => slowDownChats.contains(update.message!.chat.id),
      ),
    );

    if (mediaCount > 3) {
      await _kyaru.brain.bot.sendChatAction(
        ChatID(update.message!.chat.id),
        ChatAction.UPLOAD_PHOTO,
      );
    }
    slowDownChats.add(update.message!.chat.id);
    try {
      await _kyaru.brain.bot.sendMediaGroup(
        ChatID(update.message!.chat.id),
        httpFiles,
        replyToMessageId: update.message!.chat.type != 'private'
            ? update.message!.messageId
            : null,
      );
      print('Messages sent');
    } on APIException catch (e, s) {
      print('Could not send image: $e\n$s');
      print('${e.description}');
      if (e.description.contains('Too Many Requests: retry after ')) {
        print('Throttle...');
        var seconds = int.parse(e.description.split('after ')[1].split('(')[0]);
        await Future.delayed(Duration(seconds: seconds));
      }
      await _kyaru.brain.bot.editMessageText(
        'Error!',
        chatId: ChatID(update.message!.chat.id),
        messageId: sentMessage.messageId,
      );
    } finally {
      print('Removing id from slowed chats');
      Future.delayed(
        Duration(seconds: mediaCount * 3),
        () => slowDownChats.remove(update.message!.chat.id),
      );
    }
  }
}
