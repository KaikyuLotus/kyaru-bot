import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/genshin_client.dart';

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
}

class GenshinModule implements IModule {
  final Kyaru _kyaru;
  late GenshinClient _genshinClient;
  String? _url;

  late List<ModuleFunction> _moduleFunctions;

  GenshinModule(this._kyaru) {
    _url = _kyaru.brain.db.settings.genshinUrl;
    _genshinClient = GenshinClient(_url ?? '');
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
        'Gets your Abyss info from hoyolab.com',
        'abyss',
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

  Future saveId(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    var errorMsg =
        'This command requires an hoyolab.com user ID as parameter.\n\n'
        'To get your user ID go [here](https://www.hoyolab.com/genshin/accountCenter/postList?id=0) and check next to your name.';

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
        'hoyolab.com user id is a number, your parameter wasn\'t.',
      );
    }

    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);

    var fullInfo = await _genshinClient.getUser(id);
    var cache = fullInfo['cache'];
    if (cache == 0) {
      cache = 'unknown time, sorry';
    } else {
      cache = '$cache seconds';
    }
    var info = fullInfo['data'];
    if (info['ok'] != true) {
      var errorMessage = '${info['response']}\n'
          '\n'
          'Please remember that this command has a caching system, '
          'you\'ll be able to retry in $cache.\n'
          'While you wait, please make sure that your '
          'information on hoyolab.com is public!';
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

  Future<Map<String, dynamic>?> getUserInfo(Update update) async {
    var userData = _kyaru.brain.db.getGenshinUser(update.message!.from!.id);
    if (userData == null) {
      var msg =
          'You need to register your hoyolab.com ID first.\nTo do so use /genshin\\_id command.\n\n'
          'genshin\\_id command requires an hoyolab.com user ID as parameter.\n'
          'To get your user ID go [here](https://www.hoyolab.com/genshin/accountCenter/postList?id=0) and check next to your name.\n'
          'Make sure your information is public.';
      await _kyaru.reply(
        update,
        msg,
        parseMode: ParseMode.markdown,
        hidePreview: true,
      );
      return null;
    }

    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);
    var fullInfo = await _genshinClient.getUser(userData['id']);
    var cache = fullInfo['cache'];
    if (cache == 0) {
      cache = 'unknown time, sorry';
    } else {
      cache = '$cache seconds';
    }
    var info = fullInfo['data'];
    var response = info['response'];

    if (!info['ok']) {
      var reply = '$response\n\n'
          'Please remember that this command has a caching system, '
          'you\'ll be able to retry in $cache.\n'
          'While you wait, please make sure that your '
          'information on hoyolab.com is public!';
      await _kyaru.brain.bot.editMessageText(
        reply,
        chatId: ChatID(sentMessage.chat.id),
        messageId: sentMessage.messageId,
      );
      return null;
    }

    return {
      'response': response,
      'sent': sentMessage,
    };
  }

  Future abyss(Update update, _) async {
    var data = await getUserInfo(update);
    if (data == null) {
      // User already warned, return
      return;
    }

    assembler(data, phase) {
      var mostDefeats = data['mostDefeats'];
      var sss = data['strongestSingleStrike'];
      var mostDmgTaken = data['mostDamageTaken'];
      var elemBurstCast = data['unleashedElementalBurst'];
      var elemSkillsCast = data['elementalSkillsCast'];
      var stars = data['stars'] ?? '?';
      var dd = data['deepestDescent'] ?? '?';
      var battles = data['battles'] ?? '?';

      if (mostDefeats == null ||
          sss == null ||
          mostDmgTaken == null ||
          elemBurstCast == null ||
          elemSkillsCast == null) {
        return null;
      }

      return '*$phase Lunar Phase*\n'
          'Total Stars: *$stars*\n'
          'Deepest Descent: *$dd*\n'
          'Battles: *$battles*\n'
          'Most Defeats: *${mostDefeats['value']}*'
          ' (`${characterName(mostDefeats['character'])}`)\n'
          'Strongest Strike: *${sss['value']}*'
          ' (`${characterName(sss['character'])}`)\n'
          'Most Damage Taken: *${mostDmgTaken['value']}*'
          ' (`${characterName(mostDmgTaken['character'])}`)\n'
          'Elemental Bursts: *${elemBurstCast['value']}* '
          '(`${characterName(elemBurstCast['character'])}`)\n'
          'Elemental Skills: *${elemSkillsCast['value']}*'
          ' (`${characterName(elemSkillsCast['character'])}`)\n';
    }

    var sentMessage = data['sent'];
    var abyss = data['response']['abyss'];
    var current = abyss['current'];
    var last = abyss['last'];

    var hasCurrent = current['unleashedElementalBurst']['value'] != null;
    var hasLast = last['unleashedElementalBurst']['value'] != null;

    String? currentPart;
    String? lastPart;

    if (hasCurrent) {
      currentPart = assembler(current, 'This');
    }
    if (hasLast) {
      lastPart = assembler(last, 'Previous');
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
      chatId: ChatID(sentMessage.chat.id),
      messageId: sentMessage.messageId,
      parseMode: ParseMode.markdown,
    );
  }

  Future genshin(Update update, _) async {
    var data = await getUserInfo(update);
    if (data == null) {
      // User already warned, return
      return;
    }

    var sentMessage = data['sent'];
    var response = data['response'];
    var progress = response['progress'];

    var reply = '*User info*\n'
        '*${response['daysActive']}* days active\n'
        '*${response['achievementsUnlocked']}* Achievements Unlocked\n'
        '*${response['anemoculi']}* Anemoculi\n'
        '*${response['geoculi']}* Geoculi\n'
        '*${response['charactersObtained']}* obtained characters\n'
        '*${response['waypointsUnlocked']}* unlocked Waypoints\n'
        '*${response['domainsUnlocked']}* unlocked domains\n'
        'Spiral Abyss *${response['spiralAbyss']}*\n'
        '\n'
        '*Chests Opened*\n'
        '*${response['luxuriousChestsOpened']}* Luxurious\n'
        '*${response['preciousChestsOpened']}* Precious\n'
        '*${response['exquisiteChestsOpened']}* Exquisite\n'
        '*${response['commonChestsOpened']}* Common\n'
        '\n'
        '*Exploration Progress*\n'
        '*Liyue* ${progress["liyue"]}%\n'
        '*Dragonspine* ${progress["dragonspine"]}%\n'
        '*Mondstadt* ${progress["mondstadt"]}%';

    return _kyaru.brain.bot.editMessageText(
      reply,
      chatId: ChatID(sentMessage.chat.id),
      messageId: sentMessage.messageId,
      parseMode: ParseMode.markdown,
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
