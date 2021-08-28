import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/jikan_client.dart';

class JikanModule implements IModule {
  final Kyaru _kyaru;
  final JikanClient jikanClient = JikanClient();

  late List<ModuleFunction> _moduleFunctions;

  JikanModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        anime,
        'Search for an anime',
        'anime',
        core: true,
      ),
      ModuleFunction(
        character,
        'Search for a character',
        'character',
        core: true,
      )
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future anime(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a search string, which rappresents an anime name,'
        ' as first argument.',
      );
    }

    var searchString = args.join(' ');

    if (searchString.length < 3) {
      return _kyaru.reply(
        update,
        'Search term length must be greater than 2 characters',
      );
    }

    var matchingAnimes = await jikanClient.searchAnime(searchString);

    if (matchingAnimes == null || matchingAnimes.isEmpty) {
      return _kyaru.reply(
        update,
        'No anime found with the given search terms',
      );
    }

    var anime = matchingAnimes.first;

    var hiddenLink = MarkdownUtils.generateHiddenUrl(anime.imageUrl);
    var score = MarkdownUtils.escape('${anime.score}');
    var title = MarkdownUtils.escape(anime.title);
    var episodes = anime.episodes == 0 ? '?' : anime.episodes;
    var startDate = anime.startDate;
    var endDate = anime.endDate;
    var start = '${startDate?.day}/${startDate?.month}/${startDate?.year}';
    var end = '${endDate?.day}/${endDate?.month}/${endDate?.year}';
    var date = startDate != null
        ? MarkdownUtils.escape('$start - ${endDate != null ? end : '?'}')
        : '';
    var desc = MarkdownUtils.escape(anime.synopsis);

    var reply = '$hiddenLink*$title*\n'
        'Score: *$score* out of *10*\n'
        '*$episodes* Episodes\n'
        '$date\n\n'
        '$desc';

    var keyboard = InlineKeyboardMarkup([
      [
        InlineKeyboardButton.url(
          'Open on MAL',
          Uri.parse(anime.url).toString(),
        )
      ]
    ]);

    return _kyaru.reply(
      update,
      reply,
      parseMode: ParseMode.markdownV2,
      replyMarkup: keyboard,
    );
  }

  Future character(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a search string, which '
        'rappresents a character name, as first argument.',
      );
    }

    var searchString = args.join(' ');

    if (searchString.length < 3) {
      return _kyaru.reply(
        update,
        'Search term length must be greater than 2 characters',
      );
    }

    var matchingCharacters = await jikanClient.searchCharacter(searchString);

    if (matchingCharacters == null || matchingCharacters.isEmpty) {
      return _kyaru.reply(
        update,
        'No character found with the given search terms',
      );
    }

    var character = matchingCharacters.first;

    var hiddenLink = MarkdownUtils.generateHiddenUrl(character.imageUrl);
    var name = MarkdownUtils.escape(character.name);
    var alternativeName = character.alternativeNames.isNotEmpty
        ? MarkdownUtils.escape('(${character.alternativeNames.first})')
        : '';

    var anime = character.anime
        .map((a) => MarkdownUtils.generateUrl(
              a.name!,
              Uri.parse(a.url!).toString(),
            ))
        .join('\n');

    var manga = character.manga
        .map((m) => MarkdownUtils.generateUrl(
              m.name!,
              Uri.parse(m.url!).toString(),
            ))
        .join('\n');

    var reply = '$hiddenLink*$name $alternativeName*\n\n'
        '${anime.isNotEmpty ? '*Anime List:* \n$anime\n\n' : ''}'
        '${manga.isNotEmpty ? '*Manga List:* \n$manga\n\n' : ''}';

    var keyboard = InlineKeyboardMarkup([
      [
        InlineKeyboardButton.url(
          'Open on MAL',
          Uri.parse(character.url).toString(),
        )
      ]
    ]);

    return _kyaru.reply(
      update,
      reply,
      parseMode: ParseMode.markdownV2,
      replyMarkup: keyboard,
    );
  }
}
