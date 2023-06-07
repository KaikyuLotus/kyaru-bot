import 'dart:typed_data';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';
import '../hoyolab/components/hoyolab_client.dart';
import 'components/renderer_client.dart';
import 'components/star_rail_client.dart';
import 'entities/star_rail_entities.dart';

extension on KyaruDB {
  static const _hsrDataCollection = 'hsr_data';

  void addHSRUser(int userId, int id) {
    database[_hsrDataCollection].update(
      {'user_id': userId},
      {'id': id, 'user_id': userId},
      upsert: true,
    );
  }

  Map<String, dynamic>? getHSRUser(int userId) {
    return database[_hsrDataCollection].findOne(
      filter: {'user_id': userId},
    );
  }

  void dropHSRUsers() {
    database[_hsrDataCollection].drop();
  }
}

class StarRailModule implements IModule {
  final _log = Logger('StarRailModule');

  final Kyaru _kyaru;
  late StarRailClient _hsrClient;
  late RendererClient _renderer;

  late List<ModuleFunction> _moduleFunctions;

  StarRailModule(this._kyaru) {
    _log.info("Starting HSR module");
    _hsrClient = StarRailClient(_kyaru);
    _renderer = RendererClient(
      _kyaru.brain.db.settings.genshinRendererUrl ?? '',
    );

    _moduleFunctions = [
      ModuleFunction(
        saveId,
        'Saves your hoyolab.com ID for Star Rail',
        'hsr_id',
        core: true,
      ),
      ModuleFunction(
        hsr,
        'Gets your hoyolab.com public info for Star Rail',
        'hsr',
        core: true,
      ),
      ModuleFunction(
        characters,
        'Gets your Star Rail top 8 characters',
        'hsr_chars',
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

  Future warnUseHSRIdFirst(Update update) {
    var msg = 'Please use /hsr\\_id command first.\n\n'
        'hsr\\_id command requires an in-game ID.\n'
        'Make sure your information on Hoyolab is public!\n\n'
        'You can do this command in private, your in-game '
        'id won\'t be shown anywhere.';
    return _kyaru.reply(
      update,
      msg,
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

    final server = _hsrClient.tryRecognizeServer(id, hsrServers);
    if (server == null) {
      return _kyaru.reply(
        update,
        "That doesn't look like an in-game ID",
        quote: true,
      );
    }

    var sentMessage = await _kyaru.reply(update, 'Please wait...', quote: true);

    var fullInfo = await _hsrClient.getUserIndex(
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

    _kyaru.brain.db.addHSRUser(update.message!.from!.id, id);
    return _kyaru.brain.bot.editMessageText(
      'Everything looks nice! Use /hsr to get your information!',
      chatId: ChatID(sentMessage.chat.id),
      messageId: sentMessage.messageId,
    );
  }

  Future<UserInfo?> getSafeUserIndex(Update update, int userId) async {
    var userData = _kyaru.brain.db.getHSRUser(userId);
    if (userData == null) {
      await warnUseHSRIdFirst(update);
      return null;
    }

    final gameId = userData['id'];
    var userCachedData = await _hsrClient.getUserIndex(
      userId: userId,
      gameId: gameId,
    );

    if (userCachedData.current.retcode != 0) {
      await _kyaru.reply(
        update,
        "I couldn't retrieve your user data, retry later.\n"
        "Code: ${userCachedData.current.retcode}"
        "Details: ${userCachedData.current.message}",
      );
      return null;
    }

    return userCachedData.current.data!;
  }

  Future hsr(Update update, _) async {
    final userInfo = await getSafeUserIndex(update, update.message!.from!.id);
    if (userInfo == null) return;

    final abyssProgress = userInfo.stats.abyssProcess
        .replaceAll('<unbreak>', '')
        .replaceAll('</unbreak>', '');

    final rows = <String>[];
    rows.add('*Active days*: ${userInfo.stats.activeDays}');
    rows.add('*Chests*: ${userInfo.stats.chestNum}');
    rows.add('*Achievements*: ${userInfo.stats.achievementNum}');
    rows.add('*Characters*: ${userInfo.stats.avatarNum}');
    rows.add('*Abyss Progress*:\n$abyssProgress');

    return _kyaru.reply(
      update,
      rows.join('\n'),
      parseMode: ParseMode.markdown,
    );
  }

  Future characters(Update update, _) async {
    final uid = update.message!.from!.id;
    var userData = await getSafeUserIndex(update, uid);
    if (userData == null) {
      return;
    }

    final sentMsg = await _kyaru.reply(update, 'Please wait...');
    String? msg = 'Something went wrong...';
    try {
      final avatarsData = await _hsrClient.getUserInfo(
        userId: uid,
        gameId: _kyaru.brain.db.getHSRUser(uid)!['id'],
      );
      var image = await _renderer.getCharacters(
        userData,
        avatarsData.current.data!,
        pixelRatio: 2.5,
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
