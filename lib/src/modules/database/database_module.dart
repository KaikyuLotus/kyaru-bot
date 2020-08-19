import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';

class DatabaseModule implements IModule {
  final Kyaru _kyaru;
  List<ModuleFunction> _moduleFunctions;

  DatabaseModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(registerChat, 'Adds chats to the db', 'registerChat', public: false),
    ];
  }

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future registerChat(Update update, Instruction instruction) async {
    print('Chat!');
  }
}
