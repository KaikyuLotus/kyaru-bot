import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:uuid/uuid.dart';

import '../../kyaru.dart';
import 'enums/enums.dart';

class Instruction {
  String? uuid;
  final int? chatId;
  final InstructionType instructionType;
  final InstructionEventType? instructionEventType;
  final CustomCommand? command;
  final String? function;
  final String? regex;
  final bool requireQuote;
  final bool ownerOnly;

  Instruction(
    this.chatId,
    this.instructionType,
    this.instructionEventType,
    this.command,
    this.function,
    this.regex,
    // Private boolean parameters
    // ignore: avoid_positional_boolean_parameters
    this.requireQuote,
    this.ownerOnly,
  ) : uuid = Uuid().v4();

  Instruction._(
    this.uuid,
    this.chatId,
    this.instructionType,
    this.instructionEventType,
    this.command,
    this.function,
    this.regex,
    this.requireQuote,
    this.ownerOnly,
  );

  bool checkRequirements(Update update, Settings? settings) {
    if (requireQuote) {
      if (update.message?.replyToMessage == null) {
        return false;
      }
    }
    if (ownerOnly) {
      if (update.message?.from?.id != settings!.ownerId.chatId) {
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
      json['event_type'] != null
          ? EnumHelper.decode(InstructionEventType.values, json['event_type'])
          : null,
      callIfNotNull(CustomCommand.fromJson, json['command']),
      json['function'],
      json['regex'],
      json['require_quote'] ?? false,
      json['owner_only'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'chat_id': chatId,
      'type': UpperEnums.encodeUpper(instructionType),
      'event_type': UpperEnums.encodeUpper(instructionEventType),
      'command': command?.toJson(),
      'function': function,
      'regex': regex,
      'require_quote': requireQuote,
      'owner_only': ownerOnly
    };
  }
}
