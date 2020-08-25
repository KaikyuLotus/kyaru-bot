import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';

class DatabaseModule implements IModule {
  List<ModuleFunction> _moduleFunctions;

  DatabaseModule() {
    _moduleFunctions = [
      ModuleFunction(registerChat, 'Adds chats to the db', 'registerChat'), // public: false
    ];
  }

  @override
  Future<void> init() async {}

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future registerChat(Update update, Instruction instruction) async {
    print('Chat!');
  }
}
