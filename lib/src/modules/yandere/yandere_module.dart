import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';
import 'entities/yandere_client.dart';

class YandereModule implements IModule {
  final Kyaru _kyaru;
  final YandereClient yandereClient = YandereClient();

  List<ModuleFunction> _moduleFunctions;

  YandereModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(yandere, 'Search images from yande.re', 'yandere', core: true),
      ModuleFunction(yandere, 'Search images from yande.re', 'ynd', core: true),
    ];
  }

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future yandere(Update update, Instruction instruction) async {
    var args = update.message.text.split(' ');
    args.removeAt(0);

    // If no args are specified then assume it's a random post request
    if (args.isEmpty) return await randomPost(update, instruction);

    var specifiedMode = args[0].toLowerCase();

    var modeMap = {'random': randomPost, 'tags': randomFromTags};

    for (var mode in modeMap.keys) {
      if (mode == specifiedMode) {
        return await modeMap[mode](update, instruction);
      }
    }

    return await _kyaru.reply(update, 'Specified mode not recognized');
  }

  void randomFromTags(Update update, Instruction instruction) async {
    randomPost(update, instruction, tags: update.message.text.split(' ')..removeAt(0)..removeAt(0));
  }

  void randomPost(Update update, Instruction instruction, {List<String> tags}) {
    if (tags != null) {
      tags = List.from(tags.map((t) => t.toLowerCase()));
      if (tags.isEmpty) {
        _kyaru.reply(update, 'You must specify at least a tag').catchError((e, s) => _kyaru.onError(update, e, s));
        return;
      }
    }

    tags ??= [];

    if (!AdminUtils.isNsfwAllowed(_kyaru, update.message.chat)) {
      tags.add('rating:s');
    }

    yandereClient.getPosts(tags: tags).then((randomPostList) {
      if (randomPostList.isEmpty) {
        _kyaru
            .reply(update, 'No post found with the specified tags')
            .catchError((e, s) => _kyaru.onError(update, e, s));
        return;
      }
      var randomPost = RandomUtils.choose(randomPostList);
      var photo = HttpFile.fromToken(randomPost.sampleUrl ?? randomPost.jpegUrl ?? randomPost.fileUrl);
      var count = 0;
      var tags = randomPost.tags.split(' ').takeWhile((e) {
        count++;
        return count < 11;
      });
      var tagText = tags.join(', ');
      var caption = '`${tagText}`\n\n[Post](https://yande.re/post/show/${randomPost.id})';

      if (randomPost.fileUrl != null) {
        caption += ' - [File](${randomPost.fileUrl})';
      }

      if (photo.token.endsWith('webm')) {
        caption = 'Telegram does not support .webm format\n'
            'Here\'s the media link: ${photo.token}\n\n${caption}';
        _kyaru
            .reply(
              update,
              caption,
              quote: update.message.chat.type != 'private',
              parseMode: ParseMode.Markdown(),
            )
            .catchError((e, s) => _kyaru.onError(update, e, s));
      } else {
        _kyaru
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
