import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';
import 'entities/post.dart';
import 'entities/yandere_client.dart';

class YandereModule implements IModule {
  YandereModule(this._kyaru) {
    _moduleFunctions = <ModuleFunction>[
      ModuleFunction(yandere, 'Search images from yande.re', 'yandere', core: true),
      ModuleFunction(yandere, 'Search images from yande.re', 'ynd', core: true),
    ];
  }

  final Kyaru _kyaru;
  final YandereClient yandereClient = YandereClient();

  List<ModuleFunction> _moduleFunctions;

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future<void> yandere(Update update, Instruction instruction) async {
    final List<String> args = update.message.text.split(' ');
    args.removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) return randomPost(update, instruction);

    final String specifiedMode = args[0].toLowerCase();

    final Map<String, Function> modeMap = <String, Function>{'random': randomPost, 'tags': randomFromTags};

    for (final String mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return await modeMap[mode](update, instruction);
      }
    }

    return await _kyaru.reply(update, 'Specified mode not recognized');
  }

  Future<void> randomFromTags(Update update, Instruction instruction) async {
    randomPost(update, instruction, tags: update.message.text.split(' ')..removeAt(0)..removeAt(0));
  }

  void randomPost(Update update, Instruction instruction, {List<String> tags}) {
    if (tags != null) {
      tags = List<String>.from(tags.map<String>((String t) => t.toLowerCase()));
      if (tags.isEmpty) {
        _kyaru
            .reply(update, 'You must specify at least a tag')
            .catchError((Exception e, StackTrace s) => _kyaru.onError(update, e, s));
        return;
      }
    }

    tags ??= <String>[];

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message.chat)) {
      tags.add('rating:s');
    }

    yandereClient.getPosts(tags: tags).then((List<Post> randomPostList) {
      if (randomPostList.isEmpty) {
        _kyaru
            .reply(update, 'No post found with the specified tags')
            .catchError((Exception e, StackTrace s) => _kyaru.onError(update, e, s));
        return;
      }
      final Post randomPost = RandomUtils.choose(randomPostList);
      final HttpFile photo = HttpFile.fromToken(randomPost.sampleUrl ?? randomPost.jpegUrl ?? randomPost.fileUrl);
      int count = 0;
      final List<String> tags = randomPost.tags.split(' ').takeWhile((String e) {
        count++;
        return count < 11;
      }).toList();
      final String tagText = tags.join(', ');
      String caption = '`$tagText`\n\n[Post](https://yande.re/post/show/${randomPost.id})';

      if (randomPost.fileUrl != null) {
        caption += ' - [File](${randomPost.fileUrl})';
      }

      if (photo.token.endsWith('webm')) {
        caption = 'Telegram does not support .webm format\n'
            'Here\'s the media link: ${photo.token}\n\n$caption';
        _kyaru
            .reply(
              update,
              caption,
              quote: update.message.chat.type != 'private',
              parseMode: ParseMode.Markdown(),
            )
            .catchError((Exception e, StackTrace s) => _kyaru.onError(update, e, s));
      } else {
        _kyaru
            .replyPhoto(
              update,
              photo,
              caption: caption,
              quote: update.message.chat.type != 'private',
              parseMode: ParseMode.Markdown(),
            )
            .catchError((Exception e, StackTrace s) => _kyaru.onError(update, e, s));
      }
    }).catchError((Exception e, StackTrace s) => _kyaru.onError(update, e, s));
  }
}
