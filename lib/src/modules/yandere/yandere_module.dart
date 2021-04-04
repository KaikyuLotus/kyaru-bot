import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/yandere_client.dart';

class YandereModule implements IModule {
  final Kyaru _kyaru;
  final YandereClient yandereClient = YandereClient();
  late List<ModuleFunction> _moduleFunctions;

  YandereModule(this._kyaru) {
    _moduleFunctions = <ModuleFunction>[
      ModuleFunction(
        yandere,
        'Search images from yande.re',
        'yandere',
        core: true,
      ),
      ModuleFunction(
        yandere,
        'Search images from yande.re',
        'ynd',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future<void> yandere(Update update, _) async {
    final args = update.message!.text!.split(' ')..removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) {
      return randomPost(update, _);
    }

    final specifiedMode = args[0].toLowerCase();

    final modeMap = <String, Function>{
      'random': randomPost,
      'tags': randomFromTags
    };

    for (final mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return modeMap[mode]!(update, _);
      }
    }

    await _kyaru.reply(update, 'Specified mode not recognized');
  }

  Future<void> randomFromTags(Update update, _) async {
    randomPost(
      update,
      _,
      tags: update.message!.text!.split(' ')..removeAt(0)..removeAt(0),
    );
  }

  void randomPost(
    Update update,
    _, {
    List<String>? tags,
  }) {
    var elaboratedTags = tags;
    if (elaboratedTags != null) {
      elaboratedTags = List.from(
        elaboratedTags.map((t) => t.toLowerCase()),
      );
      if (elaboratedTags.isEmpty) {
        _kyaru.reply(update, 'You must specify at least a tag [e:1]');
        return;
      }
    }

    elaboratedTags ??= <String>[];

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message!.chat)) {
      elaboratedTags.add('rating:s');
    }

    yandereClient.getPosts(tags: elaboratedTags).then((randomPostList) {
      if (randomPostList!.isEmpty) {
        _kyaru.reply(update, 'No post found with the specified tags');
        return;
      }
      final randomPost = choose(randomPostList);
      final photo = HttpFile.fromToken(
          randomPost.sampleUrl ?? randomPost.jpegUrl ?? randomPost.fileUrl!);
      var count = 0;
      final tags = randomPost.tags.split(' ').takeWhile((e) {
        count++;
        return count < 11;
      }).toList();
      final tagText = tags.join(', ');
      var caption =
          '`$tagText`\n\n[Post](https://yande.re/post/show/${randomPost.id})';

      if (randomPost.fileUrl != null) {
        caption += ' - [File](${randomPost.fileUrl})';
      }

      if (photo.token!.endsWith('webm')) {
        caption = 'Telegram does not support .webm format\n'
            'Here\'s the media link: ${photo.token}\n\n$caption';
        _kyaru.reply(
          update,
          caption,
          quote: update.message!.chat.type != 'private',
          parseMode: ParseMode.markdown,
        );
      } else {
        _kyaru.replyPhoto(
          update,
          photo,
          caption: caption,
          quote: update.message!.chat.type != 'private',
          parseMode: ParseMode.markdown,
        );
      }
    });
  }
}
