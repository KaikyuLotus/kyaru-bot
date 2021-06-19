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
      ),
      ModuleFunction(
        constellations,
        'Gets informations about a character constellations',
        'genshin_constellations',
        core: true,
      ),
      ModuleFunction(
        weapon,
        'Gets informations about a weapon',
        'genshin_weapon',
        core: true,
      ),
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

  Future constellations(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a character name as first argument.',
      );
    }

    var name = args.join(' ');

    try {
      var result = await _genshinDataClient.getConstellations(name);
      var constellations = result.constellations
          .map((e) => '*${e.name}*\n${e.effect.replaceAll('**', '*')}\n\n')
          .join('');
      return _kyaru.reply(
        update,
        '${result.character}\n\n$constellations',
        parseMode: ParseMode.markdown,
      );
    } on GenshinDataException {
      return _kyaru.reply(update, 'Character not found');
    }
  }

  Future weapon(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a weapon name as first argument.',
      );
    }

    var ref = 1;

    if (int.tryParse(args.first) != null) {
      ref = int.parse(args.removeAt(0)).clamp(1, 5);
    }
    ref--;
    var name = args.join(' ');

    try {
      var weapon = await _genshinDataClient.getWeapon(name);
      var weaponName = MarkdownUtils.escape(weapon.name);
      var description = MarkdownUtils.escape(weapon.description);
      var effectName = MarkdownUtils.escape(weapon.effectName);
      var effect = MarkdownUtils.escape(weapon.effect)!;
      var reg = RegExp(r'\\{(\w*)\\}');
      effect = effect.replaceAllMapped(reg,
          (match) => '*${weapon.refinement[ref][int.parse(match.group(1)!)]}*');
      return _kyaru.reply(
        update,
        '*$weaponName*\n\n$description\n\n'
        '*Rarity:* ${'★' * weapon.rarity}\n'
        '*Type:* ${weapon.weaponType}\n'
        '*Sub Stat:* ${weapon.subStat}\n\n'
        '*$effectName*\n'
        '$effect',
        parseMode: ParseMode.markdownV2,
      );
    } on GenshinDataException {
      return _kyaru.reply(update, 'Weapon not found');
    }
  }
}
