import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/jikan_client.dart';

class JikanModule implements IModule {
  final Kyaru _kyaru;
  final JikanClient jikanClient = JikanClient();

  List<ModuleFunction>? _moduleFunctions;

  JikanModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        anime,
        'Search for an anime',
        'anime',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction>? getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future anime(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return await _kyaru.reply(
        update,
        'This commands needs a search string, which rappresents an anime name,'
        ' as first argument.',
      );
    }

    var searchString = args.join(' ');

    if (searchString.length < 3) {
      return await _kyaru.reply(
        update,
        'Search term length must be greater than 2 characters',
      );
    }

    var matchingAnimes = await jikanClient.search(searchString);

    if (matchingAnimes == null || matchingAnimes.isEmpty) {
      return await _kyaru.reply(
        update,
        'No anime found with the given search terms',
      );
    }

    var anime = matchingAnimes.first;

    var hiddenLink = MarkdownUtils.generateHiddenUrl(anime.imageUrl);
    var score = MarkdownUtils.escape('${anime.score}');
    var title = MarkdownUtils.escape(anime.title);
    var desc = MarkdownUtils.escape(anime.synopsis);
    var reply = '$hiddenLink*$title*\n'
        'Score: *$score* out of *10*\n'
        '*${anime.episodes}* Episodes\n\n'
        '$desc';

    var keyboard = InlineKeyboardMarkup([
      [InlineKeyboardButton.URL('Open on MAL', anime.url)]
    ]);

    await _kyaru.reply(
      update,
      reply,
      parseMode: ParseMode.MARKDOWNV2,
      replyMarkup: keyboard,
    );
  }
}
