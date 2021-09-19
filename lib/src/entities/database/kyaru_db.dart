import 'package:dart_mongo_lite/dart_mongo_lite.dart';

import '../../../kyaru.dart';
import '../instruction.dart';
import '../settings.dart';

class KyaruDB {
  static const _settingsCollection = 'settings';
  static const _instructionsCollection = 'instructions';
  static const _chatDataCollection = 'chat_data';

  final Database database = Database('database/database.json');

  Settings get settings {
    return database[_settingsCollection].findOneAs(Settings.fromJson)!;
  }

  set settings(Settings settings) {
    database[_settingsCollection].update(
      {'token': settings.token},
      settings.toJson(),
    );
  }

  void syncDb() => database.sync();

  void deleteCustomInstruction(Instruction instruction) {
    database[_instructionsCollection].delete(filter: {
      'uuid': instruction.uuid,
      'chat_id': instruction.chatId,
      'type': instruction.instructionType.value,
      'event_type': instruction.instructionEventType?.value,
      'function': instruction.function,
      'regex': instruction.regex,
      'require_quote': instruction.requireQuote,
    });
  }

  void addCustomInstruction(Instruction instruction) {
    database[_instructionsCollection].insert(instruction.toJson());
  }

  List<Instruction> getAllInstructions(String command) {
    return database[_instructionsCollection].findAs(Instruction.fromJson);
  }

  bool updateInstruction(Instruction instruction) {
    return database[_instructionsCollection].update(
      {'uuid': instruction.uuid},
      instruction.toJson(),
      upsert: false,
    ).isNotEmpty;
  }

  bool removeChatData(int chatId) {
    return database[_chatDataCollection].delete(filter: {'id': chatId});
  }

  void updateChatData(ChatData chatData) {
    database[_chatDataCollection].update(
      {'id': chatData.id},
      chatData.toJson(),
      upsert: true,
    );
  }

  Map<String, int> getChatCounts() {
    return {
      'private': database[_chatDataCollection].count(filter: {
        'is_private': true,
      }),
      'groups': database[_chatDataCollection].count(filter: {
        'is_private': false,
      }),
    };
  }

  List<ChatData> getChats() {
    return database[_chatDataCollection].findAs(ChatData.fromJson);
  }

  ChatData? getChatData(int chatId) {
    return database[_chatDataCollection].findOneAs(
      ChatData.fromJson,
      filter: {'id': chatId},
    );
  }

  List<Instruction> getInstructions(
    InstructionType? type,
    int chatId, {
    InstructionEventType? eventType,
  }) {
    return database[_instructionsCollection].findAs(
      Instruction.fromJson,
      filter: {
        if (type != null) 'type': type.value,
        if (eventType != null) 'event_type': eventType.value,
        'chat_id': chatId,
      },
    );
  }
}
