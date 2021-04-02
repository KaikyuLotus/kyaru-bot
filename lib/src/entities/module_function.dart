import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../kyaru.dart';

class ModuleFunction {
  String? description;
  String name;
  bool core;

  Future<dynamic> Function(Update, Instruction?) function;

  ModuleFunction(
    this.function,
    this.description,
    this.name, {
    this.core = false,
  });
}
