import 'dart:convert';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'components/honkai_client.dart';

class HonkaiModule implements IModule {
  final Kyaru _kyaru;
  late HonkaiClient _honkaiClient;

  late List<ModuleFunction> _moduleFunctions;

  HonkaiModule(this._kyaru) {
    _honkaiClient = HonkaiClient(_kyaru);

    _moduleFunctions = [
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

  // TODO
  Future characters(Update update, _) async {
    // var boppone = await _honkaiClient.getCharacters();
    return _kyaru.reply(update, 'Bop');
  }
}
