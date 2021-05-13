import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';
import 'entities/konachan_client.dart';
import 'entities/post.dart';

class KonachanModule implements IModule {
  final _log = Logger('KonachanModule');

  final Kyaru _kyaru;
  final KonachanClient konachanClient = KonachanClient();

  final slowDownChats = <int, DateTime>{};

  late List<ModuleFunction> _moduleFunctions;

  KonachanModule(this._kyaru) {
    _moduleFunctions = <ModuleFunction>[
      ModuleFunction(
        konachan,
        'Search images from konachan',
        'konachan',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future konachan(Update update, _) {
    final args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return randomPost(update, _);
    }

    final mode = args[0].toLowerCase();

    final modeMap = <String, Function>{
      'random': randomPost,
      'tags': randomFromTags,
    };

    if (!modeMap.containsKey(mode)) {
      return _kyaru.reply(update, 'Specified mode not recognized');
    }

    return modeMap[mode]!(update, _);
  }

  Future<void> randomFromTags(Update update, _) async {
    randomPost(
      update,
      _,
      tags: update.message!.text!.split(' ')..removeAt(0)..removeAt(0),
    );
  }

  Future randomPost(
    Update update,
    _, {
    List<String> tags = const [],
  }) async {
    tags.map((t) => t.toLowerCase());
    var cid = ChatID(update.message!.chat.id);

    if (slowDownChats.containsKey(update.message!.chat.id)) {
      var lockedTime = slowDownChats[update.message!.chat.id]!;
      var diff = lockedTime.difference(DateTime.now()).inSeconds;
      return _kyaru.reply(
        update,
        'Please wait $diff more seconds, you horny.',
      );
    }

    // TODO: Forbidden tags?

    var imagesCount = 1;
    if (tags.isNotEmpty) {
      var firstTagNum = int.tryParse(tags.first);
      if (firstTagNum != null) {
        tags.removeAt(0);
        imagesCount = firstTagNum;
      }
    }

    var hasRating = tags.any((e) => e.contains('rating:'));
    if (tags.length > 6 || (tags.length == 6 && !hasRating)) {
      return _kyaru.reply(update, 'You can specify up to six tags, sorry.');
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
      tags.removeWhere((t) => t.contains('rating:'));
      tags.add('rating:s');
    }

    await _kyaru.brain.bot.sendChatAction(cid, ChatAction.uploadPhoto);

    var posts = await konachanClient.getPosts(tags: tags);
    if (posts.isEmpty) {
      return _kyaru.reply(update, 'No post found with the specified tags');
    }

    String makeCaption(Post post) {
      var url = post.fileUrl ?? post.jpegUrl ?? post.sampleUrl!;

      var tagString = post.tags
          .split(' ')
          .take(10)
          .map((t) => '`${MarkdownUtils.escape(t)}`')
          .join(' ');

      var postLink = MarkdownUtils.generateUrl(
        'Post',
        'https://konachan.com/post/show/${post.id}',
      );
      var fileLink = MarkdownUtils.generateUrl(
        "File",
        url,
      );
      var caption = '$tagString\n\n$postLink \\- $fileLink';
      return caption;
    }

    posts.removeWhere((p) => p.fileUrl!.endsWith('webm'));

    posts.shuffle();
    var httpFiles = posts
        .take(imagesCount)
        .map(
          (p) => InputMediaPhoto(
            media: p.sampleUrl ?? p.jpegUrl ?? p.fileUrl!,
            caption: makeCaption(p),
            parseMode: ParseMode.markdownV2,
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
