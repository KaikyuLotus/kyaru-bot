import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:uuid/uuid.dart';

import '../../kyaru.dart';
import 'enums/enums.dart';

class InstructionAlias {
  final InstructionType instructionType;
  final CustomCommand? command;
  final String? regex;

  InstructionAlias({
    required this.instructionType,
    this.command,
    this.regex,
  });

  static InstructionAlias fromJson(Map<String, dynamic> json) {
    return InstructionAlias(
      instructionType: InstructionType.forValue(json['type']),
      command: callIfNotNull(CustomCommand.fromJson, json['command']),
      regex: json['regex'],
    );
  }

  static List<InstructionAlias> listFromJsonArray(List<dynamic> arr) {
    return List.generate(arr.length, (i) => InstructionAlias.fromJson(arr[i]));
  }

  Map<String, dynamic> toJson() {
    return {
      'type': instructionType.value,
      'command': command?.toJson(),
      'regex': regex,
    };
  }
}

class Instruction {
  String? uuid;
  final int? chatId;
  final InstructionType instructionType;
  final InstructionEventType? instructionEventType;
  final CustomCommand? command;
  final List<InstructionAlias> aliases;
  final String? function;
  final String? regex;
  final bool requireQuote;
  final bool ownerOnly;
  final bool volatile;

  Instruction({
    this.chatId,
    required this.instructionType,
    this.instructionEventType,
    this.command,
    this.function,
    this.regex,
    this.aliases = const [],
    required this.requireQuote,
    required this.ownerOnly,
    required this.volatile,
  }) : uuid = Uuid().v4();

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
    this.volatile,
    this.aliases,
  );

  bool checkRequirements(Update update, Settings? settings) {
    if (requireQuote) {
      if (update.message?.replyToMessage == null) return false;
    }
    if (ownerOnly) {
      if (update.message?.from?.id != settings!.ownerId.chatId) return false;
    }
    return true;
  }

  static Instruction fromJson(Map<String, dynamic> json) {
    return Instruction._(
      json['uuid'],
      json['chat_id'],
      InstructionType.forValue(json['type']),
      callIfNotNull(InstructionEventType.forValue, json['event_type']),
      callIfNotNull(CustomCommand.fromJson, json['command']),
      json['function'],
      json['regex'],
      json['require_quote'] ?? false,
      json['owner_only'] ?? false,
      json['volatile'] ?? false,
      InstructionAlias.listFromJsonArray(json['aliases'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'chat_id': chatId,
      'type': instructionType.value,
      'event_type': instructionEventType?.value,
      'command': command?.toJson(),
      'function': function,
      'regex': regex,
      'require_quote': requireQuote,
      'owner_only': ownerOnly,
      'volatile': volatile,
      'aliases': aliases.map((e) => e.toJson()).toList(),
    };
  }
}
