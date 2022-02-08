import 'dart:typed_data';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/honkai_entities.dart';
import 'components/honkai_client.dart';
import 'components/renderer_client.dart';

extension on KyaruDB {
  static const _honkaiDataCollection = 'honkai_data';

  void addHonkaiUser(int userId, int id) {
    database[_honkaiDataCollection].update(
      {'user_id': userId},
      {
        'id': id,
        'user_id': userId,
      },
      upsert: true,
    );
  }

  Map<String, dynamic>? getHonkaiUser(int userId) {
    return database[_honkaiDataCollection].findOne(
      filter: {'user_id': userId},
    );
  }
}

class HonkaiModule implements IModule {
  final Kyaru _kyaru;
  late HonkaiClient _honkaiClient;
  late RendererClient _rendererClient;

  late List<ModuleFunction> _moduleFunctions;

  HonkaiModule(this._kyaru) {
    _honkaiClient = HonkaiClient(_kyaru);
    _rendererClient = RendererClient(
      _kyaru.brain.db.settings.honkaiRendererUrl ?? '',
    );

    _moduleFunctions = [
      ModuleFunction(
        saveId,
        'Saves your honkai ID',
        'honkai_id',
        core: true,
      ),
      ModuleFunction(
        honkai,
        'Gets your hoyolab.com public info',
        'honkai',
        core: true,
      ),
      ModuleFunction(
        characters,
        'Gets your characters from HoYoLAB',
        'honkai_chars',
        core: true,
      ),
      ModuleFunction(
        character,
        'Gets one of yours characters from HoYoLAB',
        'honkai_char',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return true;
  }

  Future saveId(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(update, 'This command requires your ID');
    }

    var id = int.tryParse(args.first);
    if (id == null) {
      return _kyaru.reply(
        update,
        "The ID is a number, your parameter wasn't.",
      );
    }

    var fullInfo = await _honkaiClient.getUserData(
      userId: update.message!.from!.id,
      gameId: id,
    );

    if (fullInfo.current.retcode != 0) {
      return _kyaru.reply(
        update,
        'Failed to get user (error ${fullInfo.current.retcode}).\n'
        '\n'
        'Error Details:\n'
        '${fullInfo.current.message}'
        '\n\n'
        'To avoid caching issues, please retry in 60 minutes.',
      );
    }

    _kyaru.brain.db.addHonkaiUser(update.message!.from!.id, id);
    return _kyaru.reply(update, 'ID added');
  }

  Future honkai(Update update, _) async {
    var userId = update.message!.from!.id;
    var userData = _kyaru.brain.db.getHonkaiUser(userId);
    if (userData == null) {
      return _kyaru.reply(
        update,
        'Please use /honkai_id command first.\n\n'
        'honkai_id command requires an in-game ID.\n'
        'Make sure your information on Hoyolab is public!',
      );
    }

    final gameId = userData['id'];
    var userCachedData = await _honkaiClient.getUserData(
      userId: userId,
      gameId: gameId,
    );

    var current = userCachedData.current;

    if (current.retcode != 0) {
      return _kyaru.reply(
        update,
        "I couldn't retrieve your user data, retry later.\n"
        "Code: ${userCachedData.current.retcode}"
        "Details: ${userCachedData.current.message}",
      );
    }
    var curr = current.data!;
    // TODO improve
    return _kyaru.reply(
      update,
      '${curr.nickname} (Lvl. ${curr.level})\n'
      '${curr.activeDayNumber} Active Days\n'
      '${curr.battlesuit} Battlesuits (${curr.sssBattlesuit} SSS)\n'
      '${curr.weapon} Weapons (${curr.fiveStarWeapon} 5*)\n'
      '${curr.stigmata} Stigmatas (${curr.fiveStarStigmata} 5*)\n',
    );
  }

  Future characters(Update update, _) async {
    var userId = update.message!.from!.id;
    var userData = _kyaru.brain.db.getHonkaiUser(userId);
    if (userData == null) {
      return _kyaru.reply(update, 'ID not found');
    }

    var data = await _honkaiClient.getCharacters(
      userId: userId,
      gameId: userData['id'],
    );

    if (data.current.retcode != 0) {
      return _kyaru.reply(
        update,
        "I couldn't retrieve your characters, retry later.\n"
        "Code: ${data.current.retcode}",
      );
    }

    var image = await _rendererClient.getCharacters(data.current.data!);

    return _kyaru.replyPhoto(
      update,
      HttpFile.fromBytes('characters.png', Uint8List.fromList(image)),
      quote: true,
    );
  }

  Future character(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command requires a character name as argument:\n'
        '/honkai_char Starchasm Nyx',
      );
    }

    var characterName = args.join(' ').toLowerCase();

    var userId = update.message!.from!.id;
    var userData = _kyaru.brain.db.getHonkaiUser(userId);
    if (userData == null) {
      return _kyaru.reply(update, 'ID not found');
    }

    var data = await _honkaiClient.getCharacters(
      userId: userId,
      gameId: userData['id'],
    );

    if (data.current.retcode != 0) {
      return _kyaru.reply(
        update,
        "I couldn't retrieve your characters, retry later.\n"
        "Code: ${data.current.retcode}",
      );
    }

    Character? avatar;

    for (var character in data.current.data!.characters) {
      if (character.avatar.name.toLowerCase() == characterName) {
        avatar = character;
      }
    }

    if (avatar == null) {
      _kyaru.reply(update, "It seems like you don't have that character...");
      return;
    }

    var image = await _rendererClient.getCharacter(avatar);

    return _kyaru.replyPhoto(
      update,
      HttpFile.fromBytes('character.png', Uint8List.fromList(image)),
      quote: true,
    );
  }
}
