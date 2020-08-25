import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';
import 'entities/yandere_client.dart';

class YandereModule implements IModule {
  final Kyaru _kyaru;
  final YandereClient yandereClient = YandereClient();

  List<ModuleFunction> _moduleFunctions;

  YandereModule(this._kyaru) {
    _moduleFunctions = <ModuleFunction>[
      ModuleFunction(yandere, 'Search images from yande.re', 'yandere', core: true),
      ModuleFunction(yandere, 'Search images from yande.re', 'ynd', core: true),
    ];
  }

  @override
  Future<void> init() async {}

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future<void> yandere(Update update, Instruction instruction) async {
    final args = update.message.text.split(' ')..removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) {
      return randomPost(update, instruction);
    }

    final specifiedMode = args[0].toLowerCase();

    final modeMap = <String, Function>{'random': randomPost, 'tags': randomFromTags};

    for (final mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return await modeMap[mode](update, instruction);
      }
    }

    return await _kyaru.reply(update, 'Specified mode not recognized');
  }

  Future<void> randomFromTags(Update update, Instruction instruction) async {
    return randomPost(
      update,
      instruction,
      tags: update.message.text.split(' ')..removeAt(0)..removeAt(0),
    );
  }

  Future<void> randomPost(Update update, Instruction instruction, {List<String> tags}) async {
    var elaboratedTags = tags;
    if (elaboratedTags != null) {
      elaboratedTags = List<String>.from(elaboratedTags.map<String>((t) => t.toLowerCase()));
      if (elaboratedTags.isEmpty) {
        return _kyaru
            .reply(update, 'You must specify at least a tag')
            .catchError((e, s) => _kyaru.onError(update, e, s));
      }
    }

    elaboratedTags ??= <String>[];

    if (!await AdminUtils.isNsfwAllowed(_kyaru, update.message.chat)) {
      elaboratedTags.add('rating:s');
    }

    return yandereClient.getPosts(tags: elaboratedTags).then((randomPostList) {
      if (randomPostList.isEmpty) {
        return _kyaru
            .reply(update, 'No post found with the specified tags')
            .catchError((e, s) => _kyaru.onError(update, e, s));
      }
      final randomPost = choose(randomPostList);
      final photo = HttpFile.fromToken(randomPost.sampleUrl ?? randomPost.jpegUrl ?? randomPost.fileUrl);
      var count = 0;
      final tags = randomPost.tags.split(' ').takeWhile((e) {
        count++;
        return count < 11;
      }).toList();

      final tagText = tags.join(', ');
      var caption = '`$tagText`\n\n[Post](https://yande.re/post/show/${randomPost.id})';

      if (randomPost.fileUrl != null) {
        caption += ' - [File](${randomPost.fileUrl})';
      }

      if (photo.token.endsWith('webm')) {
        caption = 'Telegram does not support .webm format\n'
            'Here\'s the media link: ${photo.token}\n\n$caption';
        return _kyaru
            .reply(
              update,
              caption,
              quote: update.message.chat.type != 'private',
              parseMode: ParseMode.Markdown(),
            )
            .catchError((e, s) => _kyaru.onError(update, e, s));
      } else {
        return _kyaru
            .replyPhoto(
              update,
              photo,
              caption: caption,
              quote: update.message.chat.type != 'private',
              parseMode: ParseMode.Markdown(),
            )
            .catchError((e, s) => _kyaru.onError(update, e, s));
      }
    }).catchError((e, s) => _kyaru.onError(update, e, s));
  }
}
