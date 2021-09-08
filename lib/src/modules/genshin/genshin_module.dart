import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:kyaru_bot/src/modules/genshin/entities/renderer_client.dart';

import '../../../kyaru.dart';
import 'entities/abyss_info.dart';
import 'entities/detailed_avatar.dart';
import 'entities/genshin_client.dart';
import 'entities/image_generator.dart';
import 'entities/user_characters.dart';
import 'entities/userinfo.dart';
import 'entities/wrapped_abyss_info.dart';
import 'entities/wrapped_user_info.dart';

extension on KyaruDB {
  static const _genshinDataCollection = 'genshin_data';

  void addGenshinUser(int userId, int id) {
    database[_genshinDataCollection].update(
      {'user_id': userId},
      {'id': id, 'user_id': userId},
      true,
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
  final Kyaru _kyaru;
  late GenshinClient _genshinClient;
  late RendererClient _rendererClient;

  String? _url;

  late List<ModuleFunction> _moduleFunctions;

  GenshinModule(this._kyaru) {
    _url = _kyaru.brain.db.settings.genshinUrl;

    _genshinClient = GenshinClient(_url ?? '');
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
        stats,
        'You know',
        'genshin_stats',
      ),
      ModuleFunction(
        getRendererImage,
        'You know',
        'genshin_render',
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return _url?.isNotEmpty ?? false;
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

    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);

    var fullInfo = await _genshinClient.getUser(id);

    if (!fullInfo['ok'] || fullInfo['data']['data']['message'] != 'OK') {
      var errorMessage = 'Failed to get user.\n'
          '\n'
          'Please be sure that your info on HoYoLAB is public.\n'
          'Also make sure that your in-game ID is correct.'
          '\n'
          'To avoid caching issues, please retry in 20 minutes.';
      return _kyaru.brain.bot.editMessageText(
        errorMessage,
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
    }

    // Try to parse data
    UserInfo.fromJson(fullInfo['data']['data']['data']);

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

  Future getRendererImage(Update update, _) async {
    var wrappedUserInfo = await getUserInfo(update);
    if (wrappedUserInfo == null) return;

    var userData = _kyaru.brain.db.getGenshinUser(update.message!.from!.id);
    var avatars = wrappedUserInfo.userInfo.avatars.map((a) => a.id).toList();
    UserCharacters userCharacters = await _genshinClient.getCharacters(
      userData!['id'],
      avatars,
    );
    var bytes = await _rendererClient.getCharacter(userCharacters);
    await _kyaru.brain.bot.deleteMessage(
      ChatID(wrappedUserInfo.sentMessage.chat.id),
      wrappedUserInfo.sentMessage.messageId,
    );
    await _kyaru.brain.bot.sendPhoto(
      ChatID(update.message!.chat.id),
      HttpFile.fromBytes('image.jpg', bytes),
    );
  }

  Future<WrappedUserInfo?> getUserInfo(Update update) async {
    var userData = _kyaru.brain.db.getGenshinUser(update.message!.from!.id);
    if (userData == null) {
      await warnUseGenshinIdFirst(update);
      return null;
    }
    Map<String, dynamic> fullInfo;
    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);
    try {
      fullInfo = await _genshinClient.getUser(userData['id']);
    } on SocketException {
      await _kyaru.brain.bot.editMessageText(
        "I can't reach Genshin data server, please try later...",
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    if (!fullInfo['ok']) {
      var details = fullInfo['error'];
      await _kyaru.brain.bot.editMessageText(
        'Something broke...\nError details: $details',
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    var cacheTime = fullInfo['data']['cache_time'];
    var data = fullInfo['data']['data'];

    if (data['message'] != 'OK') {
      var code = data['retcode'];
      var message = data['message'];
      await _kyaru.brain.bot.editMessageText(
        'Something broke on Hoyolab...\nError code: $code\nMessage: "$message"',
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    var userInfo = UserInfo.fromJson(data['data']);

    UserInfo? oldUserInfo;
    if (fullInfo['data']['old_data'] != null) {
      if (fullInfo['data']['old_data']['message'] == 'OK') {
        oldUserInfo = UserInfo.fromJson(fullInfo['data']['old_data']['data']);
      }
    }

    return WrappedUserInfo(
      sentMessage: sentMessage,
      cacheTime: cacheTime,
      userInfo: userInfo,
      oldUserInfo: oldUserInfo,
    );
  }

  Future<WrappedAbyssInfo?> getAbyss(Update update) async {
    var userData = _kyaru.brain.db.getGenshinUser(update.message!.from!.id);
    if (userData == null) {
      await warnUseGenshinIdFirst(update);
      return null;
    }

    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);

    Map<String, dynamic> abyssInfo;
    try {
      abyssInfo = await _genshinClient.getAbyss(userData['id']);
    } on SocketException {
      await _kyaru.brain.bot.editMessageText(
        "I can't reach Genshin data server, please try later...",
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    if (!abyssInfo['ok']) {
      var details = abyssInfo['error'];
      await _kyaru.brain.bot.editMessageText(
        'Something broke...\nError details: $details',
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    var cacheTime = abyssInfo['data']['cache_time'];
    var currentPeriodData = abyssInfo['data']['data']['current'];
    var previousPeriodData = abyssInfo['data']['data']['previous'];

    if (currentPeriodData['message'] != 'OK' ||
        previousPeriodData['message'] != 'OK') {
      int code;
      if (currentPeriodData['message'] != 'OK') {
        code = currentPeriodData['retcode'];
      } else {
        code = previousPeriodData['retcode'];
      }
      await _kyaru.brain.bot.editMessageText(
        'Something broke on Hoyolab...\nError code: $code',
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    var currentAbyssInfo = AbyssInfo.fromJson(currentPeriodData['data']);
    var previousAbyssInfo = AbyssInfo.fromJson(previousPeriodData['data']);

    return WrappedAbyssInfo(
      sentMessage: sentMessage,
      cacheTime: cacheTime,
      current: currentAbyssInfo,
      previous: previousAbyssInfo,
    );
  }

  Future character(Update update, _) async {
    var userData = _kyaru.brain.db.getGenshinUser(update.message!.from!.id);
    if (userData == null) {
      await warnUseGenshinIdFirst(update);
      return null;
    }

    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command requires a character name as argument:\n'
        '/genshin_char Hu Tao',
      );
    }

    var characterName = args.join(' ').toLowerCase();

    var wrappedUserInfo = await getUserInfo(update);
    if (wrappedUserInfo == null) {
      // User already warned, return
      return;
    }
    var avatars = wrappedUserInfo.userInfo.avatars.map((a) => a.id).toList();

    UserCharacters userCharacters = await _genshinClient.getCharacters(
      userData['id'],
      avatars,
    );

    DetailedAvatar? avatar;

    for (var character in userCharacters.avatars) {
      if (character.name.toLowerCase() == characterName) {
        avatar = character;
        break;
      }
    }

    if (avatar == null) {
      return _kyaru.brain.bot.editMessageText(
        "It seems like you don't have that character...",
        chatId: ChatID(wrappedUserInfo.sentMessage.chat.id),
        messageId: wrappedUserInfo.sentMessage.messageId,
      );
    }

    var image = await generateCharacterImage(avatar);

    if (image == null) {
      return _kyaru.brain.bot.editMessageText(
        "Image generation failed...",
        chatId: ChatID(wrappedUserInfo.sentMessage.chat.id),
        messageId: wrappedUserInfo.sentMessage.messageId,
      );
    }

    await _kyaru.brain.bot.deleteMessage(
      ChatID(wrappedUserInfo.sentMessage.chat.id),
      wrappedUserInfo.sentMessage.messageId,
    );

    await _kyaru.brain.bot.sendPhoto(
      ChatID(wrappedUserInfo.sentMessage.chat.id),
      HttpFile.fromBytes('characters.png', Uint8List.fromList(image)),
      replyToMessageId: update.message?.messageId,
    );
  }

  Future abyss(Update update, _) async {
    var wrappedAbyssInfo = await getAbyss(update);
    if (wrappedAbyssInfo == null) {
      // User already warned, return
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

    var current = wrappedAbyssInfo.current;
    var previous = wrappedAbyssInfo.previous;

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

    return _kyaru.brain.bot.editMessageText(
      reply,
      chatId: ChatID(wrappedAbyssInfo.sentMessage.chat.id),
      messageId: wrappedAbyssInfo.sentMessage.messageId,
      parseMode: ParseMode.markdown,
    );
  }

  Future stats(Update update, _) async {
    var stats = await _genshinClient.getApiStats();
    var statsString = JsonEncoder.withIndent('  ').convert(stats['data']);
    _kyaru.reply(update, statsString);
  }

  Future genshin(Update update, _) async {
    var wrappedUserInfo = await getUserInfo(update);
    if (wrappedUserInfo == null) {
      // User already warned, return
      return;
    }

    var userInfo = wrappedUserInfo.userInfo;
    var oldUserInfo = wrappedUserInfo.oldUserInfo;

    var curr = userInfo.stats;
    var old = oldUserInfo?.stats;

    var liyuePerc = userInfo.liyue.percentage;
    var mondstadtPerc = userInfo.mondstadt.percentage;

    var inazumaPerc = userInfo.inazuma.percentage;
    var inazumaTreeLvl = userInfo.inazuma.inazumaTree.level;

    var dragonspinePerc = userInfo.dragonspine.percentage;
    var dragonspineTreeLvl = userInfo.dragonspine.dragonspineTree.level;

    var liyuePercOld = oldUserInfo?.liyue.percentage;
    var mondstadtPercOld = oldUserInfo?.mondstadt.percentage;

    var inazumaPercOld = oldUserInfo?.inazuma.percentage;
    var inazumaTreeLvlOld = oldUserInfo?.inazuma.inazumaTree.level;

    var dragonspinePercOld = oldUserInfo?.dragonspine.percentage;
    var dragonspineTreeLvlOld = oldUserInfo?.dragonspine.dragonspineTree.level;

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
      imp('Luxurious', curr.luxuriousChestNumber, old?.luxuriousChestNumber),
      imp('Precious', curr.preciousChestNumber, old?.preciousChestNumber),
      imp('Exquisite', curr.exquisiteChestNumber, old?.exquisiteChestNumber),
      imp('Common', curr.commonChestNumber, old?.commonChestNumber),
      '',
      '• *Exploration* •',
      impCityPerc('Mondstadt', mondstadtPerc, mondstadtPercOld),
      impCityPerc('Liyue', liyuePerc, liyuePercOld),
      impCityPerc('Dragonspine', dragonspinePerc, dragonspinePercOld),
      imp2(
        '  *Frostbearing Tree* level',
        dragonspineTreeLvl,
        dragonspineTreeLvlOld,
      ),
      impCityPerc('Inazuma', inazumaPerc, inazumaPercOld),
      imp2(
        "  *Sacred Sakura's Favor* level ",
        inazumaTreeLvl,
        inazumaTreeLvlOld,
      ),
    ].join('\n');

    return _kyaru.brain.bot.editMessageText(
      reply,
      chatId: ChatID(wrappedUserInfo.sentMessage.chat.id),
      messageId: wrappedUserInfo.sentMessage.messageId,
      parseMode: ParseMode.markdown,
    );
  }

  Future characters(Update update, _) async {
    var wrappedUserInfo = await getUserInfo(update);
    if (wrappedUserInfo == null) {
      // User already warned, return
      return;
    }

    await _kyaru.brain.bot.editMessageText(
      'Generating...',
      chatId: ChatID(wrappedUserInfo.sentMessage.chat.id),
      messageId: wrappedUserInfo.sentMessage.messageId,
    );

    var image = await generateAvatarsImage(wrappedUserInfo.userInfo);
    if (image == null) {
      return _kyaru.brain.bot.editMessageText(
        'Could not generate image... Sorry.',
        chatId: ChatID(wrappedUserInfo.sentMessage.chat.id),
        messageId: wrappedUserInfo.sentMessage.messageId,
      );
    }

    await _kyaru.brain.bot.deleteMessage(
      ChatID(wrappedUserInfo.sentMessage.chat.id),
      wrappedUserInfo.sentMessage.messageId,
    );

    await _kyaru.brain.bot.sendPhoto(
      ChatID(wrappedUserInfo.sentMessage.chat.id),
      HttpFile.fromBytes('characters.png', Uint8List.fromList(image)),
      replyToMessageId: update.message?.messageId,
    );
  }

  String characterName(String character) {
    var characters = {
      'Ambor': 'Amber',
      'Feiyan': 'Yanfei',
      'Noel': 'Noelle',
      'Qin': 'Jean',
    };
    return characters[character] ?? character;
  }
}
