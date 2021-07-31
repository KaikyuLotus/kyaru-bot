import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';
import 'entities/danbooru_client.dart';
import 'entities/post.dart';

class DanbooruModule implements IModule {
  final _log = Logger('DanbooruModule');

  final Kyaru _kyaru;
  final DanbooruClient dnbClient = DanbooruClient();

  final slowDownChats = <int, DateTime>{};

  late List<ModuleFunction> _moduleFunctions;

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
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future danbooru(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) {
      return randomPostAsync(update, null);
    }

    var specifiedMode = args[0].toLowerCase();

    var modeMap = {'random': randomPostAsync, 'tags': randomFromTags};

    for (var mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return modeMap[mode]!(update, null);
      }
    }

    return _kyaru.reply(update, 'Specified mode not recognized');
  }

  Future randomFromTags(Update update, _) {
    return randomPostAsync(
      update,
      _,
      tags: update.message!.text!.split(' ')
        ..removeAt(0)
        ..removeAt(0),
    );
  }

  Future randomPostAsync(Update update, _, {List<String>? tags}) async {
    var cid = ChatID(update.message!.chat.id);

    if (slowDownChats.containsKey(update.message!.chat.id)) {
      var lockedTime = slowDownChats[update.message!.chat.id]!;
      var diff = lockedTime.difference(DateTime.now()).inSeconds;
      return _kyaru.reply(update, 'Please wait $diff more seconds, you horny.');
    }

    var elaboratedTags = tags ?? [];
    elaboratedTags = List.from(elaboratedTags.map((t) => t.toLowerCase()));
    if (elaboratedTags.contains('loli') ||
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

    slowDownChats[update.message!.chat.id] = DateTime.now().add(
      Duration(seconds: imagesCount * 6),
    );
    Future.delayed(Duration(seconds: imagesCount * 6), () {
      _log.fine('Removing id from slowed chats');
      slowDownChats.remove(update.message!.chat.id);
    });

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message!.chat)) {
      elaboratedTags.removeWhere((t) => t.contains('rating'));
      elaboratedTags.add('rating:s');
    }

    await _kyaru.brain.bot.sendChatAction(cid, ChatAction.uploadPhoto);

    var randomPostList = await dnbClient.getPosts(
      tags: elaboratedTags,
      limit: 100,
    );
    if (randomPostList.isEmpty) {
      return _kyaru.reply(
        update,
        'No post found with the specified tags',
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

    var compatiblePostList = randomPostList
        .where(
          (p) => [
            ['jpg', 'jpeg', 'png'].contains(p.fileExt),
            p.largeFileUrl != null,
            p.width < 10000,
            p.height < 10000,
            byteToMB(p.fileSize) < 5
          ].every((b) => b),
        )
        .toList()
      ..shuffle();

    var httpFiles = compatiblePostList
        .take(imagesCount)
        .map(
          (p) => InputMediaPhoto(
            media: p.largeFileUrl!,
            caption: captionMaker(p),
            parseMode: ParseMode.markdown,
          ),
        )
        .toList();

    if (httpFiles.isEmpty) {
      return _kyaru.reply(
        update,
        'Telegram does not support .webm format\nTry again or with other tags.',
      );
    }

    try {
      await _kyaru.brain.bot.sendChatAction(cid, ChatAction.uploadPhoto);
      await _kyaru.brain.bot.sendMediaGroup(
        cid,
        httpFiles,
        replyToMessageId: update.message!.chat.type != 'private'
            ? update.message!.messageId
            : null,
      );
    } on APIException catch (e, s) {
      _log.severe('Could not send image: ${e.description}', e, s);
      if (e.description.contains('Too Many Requests: retry after ')) {
        _log.fine('Throttle...');
        var seconds = int.parse(e.description.split('after ')[1].split('(')[0]);
        await Future.delayed(Duration(seconds: seconds));
        await _kyaru.reply(
          update,
          "Sorry, you're too horny and Telegram throttled me for"
          " $seconds seconds.\nI'll serve your requests as soon as possible,"
          " but please slow down.",
        );
      }
    }
  }
}
