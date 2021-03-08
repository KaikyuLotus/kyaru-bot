import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:uuid/uuid.dart';

import '../../kyaru.dart';
import 'enums/enums.dart';

class Instruction {
  String? _uuid;
  int? _chatId;
  InstructionType _instructionType;
  InstructionEventType _instructionEventType;
  CustomCommand _command;
  String? _function;
  String? _regex;
  bool _requireQuote;
  bool _ownerOnly;

  String? get uuid => _uuid;

  int? get chatId => _chatId;

  InstructionType get instructionType => _instructionType;

  InstructionEventType get instructionEventType => _instructionEventType;

  CustomCommand get command => _command;

  String? get function => _function;

  String? get regex => _regex;

  bool get requireQuote => _requireQuote;

  bool get ownerOnly => _ownerOnly;

  Instruction(
    this._chatId,
    this._instructionType,
    this._instructionEventType,
    this._command,
    this._function,
    this._regex,
    // Private boolean parameters
    // ignore: avoid_positional_boolean_parameters
    this._requireQuote,
    this._ownerOnly,
  ) {
    _uuid = Uuid().v4();
  }

  Instruction._(
    this._uuid,
    this._chatId,
    this._instructionType,
    this._instructionEventType,
    this._command,
    this._function,
    this._regex,
    this._requireQuote,
    this._ownerOnly,
  );

  bool checkRequirements(Update update, Settings? settings) {
    if (requireQuote) {
      if (update.message?.replyToMessage == null) {
        return false;
      }
    }
    if (ownerOnly) {
      if (update.message?.from?.id != settings!.ownerId) {
        return false;
      }
    }
    return true;
  }

  static Instruction fromJson(Map<String, dynamic> json) {
    return Instruction._(
      json['uuid'],
      json['chat_id'],
      EnumHelper.decode(InstructionType.values, json['type']),
      EnumHelper.decode(InstructionEventType.values, json['event_type']),
      CustomCommand.fromJson(json['command']),
      json['function'],
      json['regex'],
      json['require_quote'] ?? false,
      json['owner_only'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': _uuid,
      'chat_id': _chatId,
      'type': EnumHelper.encode(_instructionType),
      'event_type': EnumHelper.encode(_instructionEventType),
      'command': _command.toJson(),
      'function': _function,
      'regex': _regex,
      'require_quote': _requireQuote,
      'owner_only': _ownerOnly
    };
  }
}
