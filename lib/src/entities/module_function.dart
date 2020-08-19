import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';

class ModuleFunction {
  Future<dynamic> Function(Update, Instruction) function;

  String description;
  String name;
  bool core;

  ModuleFunction(this.function, this.description, this.name, {bool public = true, this.core = false});
}
