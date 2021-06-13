import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/genshindata_client.dart';

class GenshinDataModule implements IModule {
  final Kyaru _kyaru;
  late GenshinDataClient _genshinDataClient;
  String? _url;

  late List<ModuleFunction> _moduleFunctions;

  GenshinDataModule(this._kyaru) {
    _url = _kyaru.brain.db.settings.genshinDataUrl;
    _genshinDataClient = GenshinDataClient(_url ?? '');
    _moduleFunctions = [
      ModuleFunction(
        character,
        'Gets informations about a character',
        'genshin_character',
        core: true,
      )
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return _url?.isNotEmpty ?? false;
  }

  Future character(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a character name as first argument.',
      );
    }
    var name = args[0];
    var level;
    if (args.length > 1) {
      level = int.tryParse(args[1])?.clamp(1, 90);
    }
    try {
      var character = await _genshinDataClient.getCharacter(name, level: level);
      var image =
          MarkdownUtils.generateHiddenUrl(character.images['hoyolab-avatar']!);
      var message = '${character.name} (${character.title})\n\n'
          '${character.description}\n\n'
          'Rarity: ${'★' * character.rarity}\n'
          'Weapon: ${character.weaponType}\n'
          'Vision: ${character.element}';
      if (character.stats != null) {
        var stats = character.stats!;
        message += '\n\nHp: ${stats.hp}\n'
            'Attack: ${stats.attack}\n'
            'Defense: ${stats.defense}\n'
            'Ascension: ${stats.ascension}\n';
        //Too dumb
        //'${character.subStat}: ${stats.specialized}%';
      }
      message = '$image${MarkdownUtils.escape(message)}';
      return _kyaru.reply(
        update,
        message,
        parseMode: ParseMode.markdownV2,
      );
    } on GenshinDataException {
      return _kyaru.reply(update, 'Character not found');
    }
  }
}
