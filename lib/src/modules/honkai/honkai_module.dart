import 'dart:typed_data';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
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
        characters,
        'Gets your characters from HoYoLAB',
        'honkai_characters',
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

    // TODO: Add check for id

    _kyaru.brain.db.addHonkaiUser(update.message!.from!.id, id);
    return _kyaru.reply(update, 'ID added');
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
}
