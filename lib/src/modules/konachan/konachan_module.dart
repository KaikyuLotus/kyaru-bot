import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/konachan_client.dart';

class KonachanModule implements IModule {
  final Kyaru _kyaru;
  final KonachanClient konachanClient = KonachanClient();
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

  // TODO: Improve
  Future randomPost(
    Update update,
    _, {
    List<String> tags = const <String>[],
  }) async {
    tags.map((t) => t.toLowerCase());

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message!.chat)) {
      tags.add('rating:s');
    }

    final posts = await konachanClient.getPosts(tags: tags);
    if (posts.isEmpty) {
      return _kyaru.reply(update, 'No post found with the specified tags');
    }

    final post = choose(posts);
    var count = 0;
    final photo =
        HttpFile.fromToken(post.sampleUrl ?? post.jpegUrl ?? post.fileUrl!);
    final tagString = MarkdownUtils.escape(post.tags.split(' ').takeWhile((v) {
      count++;
      return count < 11;
    }).join(', '));
    var postLink = MarkdownUtils.generateUrl(
      'Post',
      'https://konachan.com/post/show/${post.id}',
    );
    var fileLink = post.fileUrl == null
        ? ''
        : ' \\- ${MarkdownUtils.generateUrl(
            "File",
            post.fileUrl!,
          )}';
    var caption = '`$tagString`\n\n$postLink$fileLink';

    if (photo.token!.endsWith('webm')) {
      caption = 'Telegram does not support .webm format\n'
          'Here\'s the media link: ${photo.token}\n\n$caption';
      _kyaru.reply(
        update,
        caption,
        quote: update.message!.chat.type != 'private',
        parseMode: ParseMode.markdownV2,
      );
    } else {
      _kyaru.replyPhoto(
        update,
        photo,
        caption: caption,
        quote: update.message!.chat.type != 'private',
        parseMode: ParseMode.markdownV2,
      );
    }
  }
}
