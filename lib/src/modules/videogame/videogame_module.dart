import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/videogame_client.dart';

class VideogameModule implements IModule {
  final Kyaru _kyaru;
  late VideogameClient videogameClient;
  String? _key;

  late List<ModuleFunction> _moduleFunctions;

  VideogameModule(this._kyaru) {
    _key = _kyaru.brain.db.settings.videogameToken;
    videogameClient = VideogameClient(_key);
    _moduleFunctions = [
      ModuleFunction(
        game,
        'Get game info',
        'game',
        core: true,
      ),
      ModuleFunction(
        platforms,
        'Get a list of platforms',
        'platforms',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return _key?.isNotEmpty ?? false;
  }

  Future game(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a game title as first argument.',
      );
    }
    var game = await videogameClient.getVideogameDetails(args.join(' '));
    var description = removeAllHtmlTags(game.description);
    var platforms =
        game.platforms.map((platform) => '- ${platform.name}\n').join();
    var genres = game.genres.map((genre) => '- ${genre.name}\n').join();
    return _kyaru.reply(
      update,
      '${game.name}\n\n'
      '$description\n\n'
      'Genres:\n$genres\n'
      'Platforms:\n$platforms',
    );
  }

  Future platforms(Update update, _) async {
    var platforms = await videogameClient.getPlatformList();
    var message = platforms
        .map(
            (platform) => '- ${platform.name} (${platform.gamesCount} games)\n')
        .join();
    return _kyaru.reply(update, message);
  }
}
