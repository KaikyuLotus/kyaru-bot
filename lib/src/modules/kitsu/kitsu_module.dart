import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/kitsu_client.dart';

class KitsuModule implements IModule {
  final Kyaru _kyaru;
  final KitsuClient kitsuClient = KitsuClient();

  late List<ModuleFunction> _moduleFunctions;

  KitsuModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        anime,
        'Search for an anime on Kitsu',
        'kitsu',
        core: true,
      ),
      ModuleFunction(
        character,
        'Search for a character on Kitsu',
        'kitsu_character',
        core: true,
      ),
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
    var matchingAnimes = await kitsuClient.searchAnime(searchString);

    if (matchingAnimes == null || matchingAnimes.isEmpty) {
      return _kyaru.reply(
        update,
        'No anime found with the given search terms',
      );
    }

    var anime = matchingAnimes.first;

    var hiddenImage = MarkdownUtils.generateHiddenUrl(anime.imageLink);
    var rating = MarkdownUtils.escape(anime.averageRating);
    var title = MarkdownUtils.escape(anime.titles['en_jp']);
    var episodes = anime.episodeCount ?? '?';
    var startDate = anime.startDate;
    var endDate = anime.endDate;
    var start = '${startDate?.day}/${startDate?.month}/${startDate?.year}';
    var end = '${endDate?.day}/${endDate?.month}/${endDate?.year}';
    var date = startDate != null
        ? MarkdownUtils.escape('$start - ${endDate != null ? end : '?'}')
        : '';
    var description = MarkdownUtils.escape(anime.description);

    var reply = '$hiddenImage*$title*\n'
        'Average Rating: *$rating*\n'
        'Episodes: $episodes\n'
        '$date\n\n'
        '$description';

    var keyboard = InlineKeyboardMarkup([
      [InlineKeyboardButton.url('Open on Kitsu', anime.url)]
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

    var matchingCharacters = await kitsuClient.searchCharacter(searchString);

    if (matchingCharacters == null || matchingCharacters.isEmpty) {
      return _kyaru.reply(
        update,
        'No character found with the given search terms',
      );
    }

    var character = matchingCharacters.first;

    var hiddenLink = MarkdownUtils.generateHiddenUrl(character.imageUrl ?? '');
    var name = MarkdownUtils.escape(character.names['en']);
    var alternativeName = character.otherNames.isNotEmpty
        ? MarkdownUtils.escape('(${character.otherNames.first})')
        : '';
    var description =
        MarkdownUtils.escape(removeAllHtmlTags(character.description));

    var reply = '$hiddenLink*$name $alternativeName*\n\n'
        '$description';

    return _kyaru.reply(
      update,
      reply,
      parseMode: ParseMode.markdownV2,
    );
  }
}
