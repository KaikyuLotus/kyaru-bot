import 'dart:async';
import 'dart:typed_data';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';
import 'components/genshin_client.dart';
import 'components/renderer_client.dart';
import 'entities/genshin_entities.dart';

extension on KyaruDB {
  static const _genshinDataCollection = 'genshin_data';

  void addGenshinUser(int userId, int id) {
    database[_genshinDataCollection].update(
      {'user_id': userId},
      {'id': id, 'user_id': userId},
      upsert: true,
    );
  }

  Map<String, dynamic>? getGenshinUser(int userId) {
    return database[_genshinDataCollection].findOne(
      filter: {'user_id': userId},
    );
  }

  void dropGenshinUsers() {
    database[_genshinDataCollection].drop();
  }
}

class GenshinModule implements IModule {
  final _log = Logger('GenshinModule');

  final Kyaru _kyaru;
  late GenshinClient _genshinClient;
  late RendererClient _rendererClient;

  late List<ModuleFunction> _moduleFunctions;

  GenshinModule(this._kyaru) {
    _genshinClient = GenshinClient(_kyaru);
    _rendererClient = RendererClient(
      _kyaru.brain.db.settings.genshinRendererUrl ?? '',
    );

    _moduleFunctions = [
      ModuleFunction(
        saveId,
        'Saves your hoyolab.com ID',
        'genshin_id',
        core: true,
      ),
      ModuleFunction(
        genshin,
        'Gets your hoyolab.com public info',
        'genshin',
        core: true,
      ),
      ModuleFunction(
        abyss,
        'Gets your hoyolab.com public info',
        'abyss',
        core: true,
      ),
      ModuleFunction(
        delGenshinUsers,
        'Delete genshin users from db',
        'del_genshin_users',
        core: false,
      ),
      ModuleFunction(
        characters,
        'Gets your characters from HoYoLAB',
        'genshin_chars',
        core: true,
      ),
      ModuleFunction(
        character,
        'Gets one of yours characters from HoYoLAB',
        'genshin_char',
        core: true,
      ),
      ModuleFunction(
        setRendererUrl,
        'Owner only command that sets genshin renderer url',
        'set_renderer_url',
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return true;
  }

  Future setRendererUrl(Update update, _) async {
    final parts = update.message!.text!.split(' ')..removeAt(0);
    if (parts.isEmpty) {
      return _kyaru.reply(update, 'This command requires an url as parameter');
    }

    final oldUri = _rendererClient.baseUrl;
    try {
      _rendererClient.baseUrl = parts.first;
      await _rendererClient.health();
      _kyaru.brain.db.settings = _kyaru.brain.db.settings.copyWith(
        genshinRendererUrl: parts.first,
      );
      _kyaru.reply(update, 'Done!');
    } catch (e, s) {
      _rendererClient.baseUrl = oldUri;
      _kyaru.reply(update, 'There was an error: $e');
      _log.severe('Error while trying to change genshin renderer url', e, s);
    }
  }

  Future delGenshinUsers(Update update, _) async {
    _kyaru.brain.db.dropGenshinUsers();
    await _kyaru.reply(
      update,
      'Done.',
      parseMode: ParseMode.markdown,
      hidePreview: true,
    );
  }

  Future saveId(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    var errorMsg = 'This command requires your in-game user ID as parameter.\n'
        'Please remember that your info on HoYoLAB must be public.';

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        errorMsg,
        parseMode: ParseMode.markdown,
        hidePreview: true,
      );
    }

    var id = int.tryParse(args.first);
    if (id == null) {
      return _kyaru.reply(
        update,
        "in-game id is a number, your parameter wasn't.",
      );
    }

    final server = _genshinClient.tryRecognizeServer(id);
    if (server == null) {
      return _kyaru.reply(
        update,
        "That doesn't look like an in-game ID",
        quote: true,
      );
    }

    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);

    var fullInfo = await _genshinClient.getUserData(
      userId: update.message!.from!.id,
      gameId: id,
    );

    if (fullInfo.current.retcode != 0) {
      var errorMessage =
          'Failed to get user (error ${fullInfo.current.retcode}).\n'
          '\n'
          'Error Details:\n'
          '${fullInfo.current.message}'
          '\n\n'
          'To avoid caching issues, please retry in 60 minutes.';
      return _kyaru.brain.bot.editMessageText(
        errorMessage,
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
    }

    _kyaru.brain.db.addGenshinUser(update.message!.from!.id, id);
    return _kyaru.brain.bot.editMessageText(
      'Everything looks nice! Use /genshin to get your information!',
      chatId: ChatID(sentMessage.chat.id),
      messageId: sentMessage.messageId,
    );
  }

  Future warnUseGenshinIdFirst(Update update) {
    var msg = 'Please use /genshin\\_id command first.\n\n'
        'genshin\\_id command requires an in-game ID.\n'
        'Make sure your information on Hoyolab is public!\n\n'
        'If you had already registered your id in the past:\n'
        'due to an update, now I work with in-game user id, '
        'so all old IDs have been removed.\n'
        'You can do this command in private, your in-game '
        'id won\'t be shown anywhere.\n'
        'Thanks for understanding.';
    return _kyaru.reply(
      update,
      msg,
      parseMode: ParseMode.markdown,
      hidePreview: true,
    );
  }

  static String characterName(String character) {
    const characters = {
      'Ambor': 'Amber',
      'Feiyan': 'Yanfei',
      'Noel': 'Noelle',
      'Qin': 'Jean',
      'PlayerGirl': 'Lumine',
      'PlayerBoy': 'Aether',
      'Hutao': 'Hu Tao',
      'Shogun': 'Raiden Shogun',
      'Ayaka': 'Kamisato Ayaka',
      'Kokomi': 'Sangonomiya Kokomi',
      'Sara': 'Kujou Sara',
      'Yunjin': 'Yun Jin',
    };
    return characters[character] ?? character;
  }

  Future abyss(Update update, _) async {
    var userData = _kyaru.brain.db.getGenshinUser(update.message!.from!.id);
    if (userData == null) {
      await warnUseGenshinIdFirst(update);
      return;
    }

    wTrue(e) => true;

    String? assembler(AbyssInfo data, String phase) {
      var mostDefeats = data.defeatRank.where(wTrue);

      var sss = data.damageRank.where(wTrue);
      var mostDmgTaken = data.takeDamageRank.where(wTrue);
      var elemBurstCast = data.energySkillRank.where(wTrue);
      var elemSkillsCast = data.normalSkillRank.where(wTrue);
      var stars = data.totalStar;
      var dd = data.maxFloor;
      var battles = data.totalBattleTimes;

      if (mostDefeats.isEmpty ||
          sss.isEmpty ||
          mostDmgTaken.isEmpty ||
          elemBurstCast.isEmpty ||
          elemSkillsCast.isEmpty) {
        return null;
      }

      return '*$phase Lunar Phase*\n'
          'Total Stars: *$stars*\n'
          'Deepest Descent: *$dd*\n'
          'Battles: *$battles*\n'
          'Most Defeats: *${mostDefeats.first.value}*'
          ' (`${characterName(mostDefeats.first.name)}`)\n'
          'Strongest Strike: *${sss.first.value}*'
          ' (`${characterName(sss.first.name)}`)\n'
          'Most Damage Taken: *${mostDmgTaken.first.value}*'
          ' (`${characterName(mostDmgTaken.first.name)}`)\n'
          'Elemental Bursts: *${elemBurstCast.first.value}* '
          '(`${characterName(elemBurstCast.first.name)}`)\n'
          'Elemental Skills: *${elemSkillsCast.first.value}*'
          ' (`${characterName(elemSkillsCast.first.name)}`)\n';
    }

    final gameId = userData['id'];
    var abyssCachedData = await _genshinClient.getSpiralAbyss(
      userId: update.message!.from!.id,
      gameId: gameId,
    );

    if (abyssCachedData.currentPeriod.current.retcode != 0 ||
        abyssCachedData.previousPeriod.current.retcode != 0) {
      return _kyaru.reply(
        update,
        "I couldn't retrieve your abyss data, retry later.",
      );
    }

    var current = abyssCachedData.currentPeriod.current.data!;
    var previous = abyssCachedData.previousPeriod.current.data!;

    var hasCurrent = current.totalBattleTimes > 0;
    var hasPrevious = previous.totalBattleTimes > 0;

    String? currentPart;
    String? lastPart;

    if (hasCurrent) {
      currentPart = assembler(current, 'Current');
    }
    if (hasPrevious) {
      lastPart = assembler(previous, 'Previous');
    }

    var reply = 'No abyss information found...';
    if (currentPart != null || lastPart != null) {
      reply = '';
      if (currentPart != null) {
        reply += '$currentPart\n';
      }
      if (lastPart != null) {
        reply += lastPart;
      }
    }

    return _kyaru.reply(
      update,
      reply,
      parseMode: ParseMode.markdown,
    );
  }

  Future genshin(Update update, _) async {
    var userId = update.message!.from!.id;
    var userData = _kyaru.brain.db.getGenshinUser(userId);
    if (userData == null) {
      await warnUseGenshinIdFirst(update);
      return;
    }

    final gameId = userData['id'];
    var userCachedData = await _genshinClient.getUserData(
      userId: userId,
      gameId: gameId,
    );

    if (userCachedData.current.retcode != 0) {
      return _kyaru.reply(
        update,
        "I couldn't retrieve your user data, retry later.\n"
        "Code: ${userCachedData.current.retcode}"
        "Details: ${userCachedData.current.message}",
      );
    }

    var userInfo = userCachedData.current.data!;
    var oldUserInfo = userCachedData.previous?.data;

    var curr = userInfo.stats;
    var old = oldUserInfo?.stats;

    var liyuePerc = userInfo.liyue?.percentage;
    var mondstadtPerc = userInfo.mondstadt?.percentage;
    var enkanomiyaPerc = userInfo.enkanomiya?.percentage;

    var inazumaPerc = userInfo.inazuma?.percentage;
    var inazumaTreeLvl = userInfo.inazumaTree?.level;

    var dragonspinePerc = userInfo.dragonspine?.percentage;
    var dragonspineTreeLvl = userInfo.dragonspineTree?.level;

    var theChasmPerc = userInfo.theChasm?.percentage;
    var theChasmUndergroundPerc = userInfo.theChasmUndergroundMines?.percentage;
    var theChasmOfferingLvl = userInfo.theChasmLumenstoneAdjuvant?.level;

    var liyuePercOld = oldUserInfo?.liyue?.percentage;
    var mondstadtPercOld = oldUserInfo?.mondstadt?.percentage;
    var enkanomiyaPercOld = oldUserInfo?.enkanomiya?.percentage;

    var inazumaPercOld = oldUserInfo?.inazuma?.percentage;
    var inazumaTreeLvlOld = oldUserInfo?.inazumaTree?.level;

    var dragonspinePercOld = oldUserInfo?.dragonspine?.percentage;
    var dragonspineTreeLvlOld = oldUserInfo?.dragonspineTree?.level;

    var theChasmPercOld = oldUserInfo?.theChasm?.percentage;
    var theChasmUndergroundPercOld =
        oldUserInfo?.theChasmUndergroundMines?.percentage;
    var theChasmOfferingLvlOld = oldUserInfo?.theChasmLumenstoneAdjuvant?.level;

    String imp(String name, int current, int? old) {
      if (old == null) return '*$current* $name';
      if (current == old) return '*$current* $name';
      return '*$current* (+${current - old}) $name';
    }

    String imp2(String name, int current, int? old) {
      if (old == null) return '$name *$current*';
      if (current == old) return '$name *$current*';
      return '$name *$current* (+${current - old})';
    }

    String impCityPerc(String name, num current, num? old) {
      if (old == null) return '$name *$current*%';
      if (current == old) return '$name *$current*%';
      return '$name *$current*% (+${(current - old).toStringAsFixed(2)}%)';
    }

    String change(String current, String? old) {
      if (old == null) return '*$current*';
      if (current == old) return '*$current*';
      return '*$old* -> *$current*';
    }

    var reply = [
      '• *Info* •',
      imp('Active Days', curr.activeDayNumber, old?.activeDayNumber),
      imp('Achievements', curr.achievementNumber, old?.achievementNumber),
      imp('Characters', curr.avatarNumber, old?.avatarNumber),
      imp('Waypoints', curr.wayPointNumber, old?.wayPointNumber),
      imp('Domains', curr.domainNumber, old?.domainNumber),
      imp('Electroculus', curr.electroculusNumber, old?.electroculusNumber),
      imp('Anemoculus', curr.anemoculusNumber, old?.anemoculusNumber),
      imp('Geoculus', curr.geoculusNumber, old?.geoculusNumber),
      'Spiral Abyss ${change(curr.spiralAbyss, old?.spiralAbyss)}',
      '',
      '• *Chests* •',
      imp('Remarkable', curr.magicChestNumber, old?.magicChestNumber),
      imp('Luxurious', curr.luxuriousChestNumber, old?.luxuriousChestNumber),
      imp('Precious', curr.preciousChestNumber, old?.preciousChestNumber),
      imp('Exquisite', curr.exquisiteChestNumber, old?.exquisiteChestNumber),
      imp('Common', curr.commonChestNumber, old?.commonChestNumber),
      '',
      '• *Exploration* •',
      if (mondstadtPerc != null)
        impCityPerc('Mondstadt', mondstadtPerc, mondstadtPercOld),
      if (liyuePerc != null) impCityPerc('Liyue', liyuePerc, liyuePercOld),
      if (dragonspinePerc != null)
        impCityPerc('Dragonspine', dragonspinePerc, dragonspinePercOld),
      if (dragonspineTreeLvl != null)
        imp2(
          '  *Frostbearing Tree* level',
          dragonspineTreeLvl,
          dragonspineTreeLvlOld,
        ),
      if (inazumaPerc != null)
        impCityPerc('Inazuma', inazumaPerc, inazumaPercOld),
      if (inazumaTreeLvl != null)
        imp2(
          "  *Sacred Sakura's Favor* level ",
          inazumaTreeLvl,
          inazumaTreeLvlOld,
        ),
      if (enkanomiyaPerc != null)
        impCityPerc(
          'Enkanomiya',
          enkanomiyaPerc,
          enkanomiyaPercOld,
        ),
      if (theChasmPerc != null)
        impCityPerc(
          'The Chasm',
          theChasmPerc,
          theChasmPercOld,
        ),
      if (theChasmUndergroundPerc != null)
        impCityPerc(
          'The Chasm: Underground Mines',
          theChasmUndergroundPerc,
          theChasmUndergroundPercOld,
        ),
      if (theChasmOfferingLvl != null)
        imp2(
          "  *Lumenstone Adjuvant* level ",
          theChasmOfferingLvl,
          theChasmOfferingLvlOld,
        ),
    ];

    if (userInfo.homes.isNotEmpty) {
      final curHome = userInfo.homes.first;
      final oldHome =
          oldUserInfo?.homes.isEmpty ?? true ? null : oldUserInfo?.homes.first;
      reply.addAll([
        '',
        '• *Teapot* •',
        change(curHome.name, oldHome?.name),
        imp2('Level', curHome.level, oldHome?.level) +
            ' (${change(curHome.comfortLevelName, oldHome?.comfortLevelName)})',
        imp2('Comfort', curHome.comfortNum, oldHome?.comfortNum),
        imp2('Visits', curHome.visitNum, oldHome?.visitNum),
        imp2('Items', curHome.itemNum, oldHome?.itemNum),
      ]);
    }

    return _kyaru.reply(
      update,
      reply.join('\n'),
      parseMode: ParseMode.markdown,
    );
  }

  Future character(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command requires a character name as argument:\n'
        '/genshin_char Hu Tao',
      );
    }

    var characterName = args.join(' ').toLowerCase();

    final sentMsg = await _kyaru.reply(update, 'Please wait...');
    String? msg = 'Something went wrong...';
    var userId = update.message!.from!.id;
    try {
      var userData = _kyaru.brain.db.getGenshinUser(userId);
      if (userData == null) {
        await warnUseGenshinIdFirst(update);
        return;
      }
      final gameId = userData['id'];
      var userDataCache = await _genshinClient.getUserData(
        userId: userId,
        gameId: gameId,
      );

      if (userDataCache.current.retcode != 0) {
        msg = "I couldn't retrieve your user data, retry later.\n"
            "Code: ${userDataCache.current.retcode}\n"
            "Details: ${userDataCache.current.message}";
        return;
      }

      final ids = userDataCache.current.data!.avatars.map((a) => a.id).toList();
      final charactersCache = await _genshinClient.getCharacters(
        userId: userId,
        gameId: gameId,
        characterIdsJson: ids,
      );

      DetailedAvatar? avatar;

      if (charactersCache.current.retcode != 0) {
        msg = "I couldn't retrieve your characters, retry later.\n"
            "Code: ${charactersCache.current.retcode}";
        return;
      }

      for (var character in charactersCache.current.data!.avatars) {
        if (character.name.toLowerCase() == characterName) {
          avatar = character;
          break;
        }
      }

      if (avatar == null) {
        msg = "That character is not in your top 8, or you don't have it.";
        return;
      }

      var bytes = await _rendererClient.getCharacter(
        avatar,
        pixelRatio: 1.5,
      );
      await _kyaru.replyPhoto(
        update,
        HttpFile.fromBytes('character.png', bytes),
      );
      msg = null;
    } catch (e) {
      msg = null;
      rethrow;
    } finally {
      if (msg == null) {
        await _kyaru.deleteMessage(update, sentMsg);
      } else {
        await _kyaru.editMessage(update, sentMsg, msg);
      }
    }
  }

  Future characters(Update update, _) async {
    var userId = update.message!.from!.id;
    var userData = _kyaru.brain.db.getGenshinUser(userId);
    if (userData == null) {
      await warnUseGenshinIdFirst(update);
      return;
    }

    final sentMsg = await _kyaru.reply(update, 'Please wait...');
    String? msg = 'Something went wrong...';
    try {
      final gameId = userData['id'];
      var userCachedData = await _genshinClient.getUserData(
        userId: userId,
        gameId: gameId,
      );

      if (userCachedData.current.retcode != 0) {
        msg = "I couldn't retrieve your user data, retry later.\n"
            "Code: ${userCachedData.current.retcode}\n"
            "Details: ${userCachedData.current.message}";
        return;
      }

      var image = await _rendererClient.getCharacters(
        userCachedData.current.data!,
        pixelRatio: 1.2,
      );

      await _kyaru.replyPhoto(
        update,
        HttpFile.fromBytes('characters.png', Uint8List.fromList(image)),
        quote: true,
      );
      msg = null;
    } catch (e) {
      msg = null;
      rethrow;
    } finally {
      if (msg == null) {
        await _kyaru.deleteMessage(update, sentMsg);
      } else {
        await _kyaru.editMessage(update, sentMsg, msg);
      }
    }
  }
}
