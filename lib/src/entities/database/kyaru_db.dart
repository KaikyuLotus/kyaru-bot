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
    return database[_settingsCollection].findOneAs(
      (json) => Settings.fromJson(json),
    )!;
  }

  void syncDb() => database.sync();

  void deleteCustomInstruction(Instruction instruction) {
    database[_instructionsCollection].delete({
      'uuid': instruction.uuid,
      'chat_id': instruction.chatId,
      'type': UpperEnums.encodeUpper(instruction.instructionType),
      'event_type': UpperEnums.encodeUpper(instruction.instructionEventType),
      'function': instruction.function,
      'regex': instruction.regex,
      'require_quote': instruction.requireQuote,
    });
  }

  void addCustomInstruction(Instruction instruction) {
    database[_instructionsCollection].insert(instruction.toJson());
  }

  void updateChatData(ChatData chatData) {
    database[_chatDataCollection].update(
      {'id': chatData.id},
      chatData.toJson(),
      true,
    );
  }

  ChatData? getChatData(int chatId) {
    return database[_chatDataCollection].findOneAs(
      (json) => ChatData.fromJson(json),
      filter: {'id': chatId},
    );
  }

  List<Instruction> getInstructions(
    InstructionType type,
    int chatId, {
    InstructionEventType? eventType,
  }) {
    var filter = {'type': UpperEnums.encodeUpper(type), 'chat_id': chatId};
    if (eventType != null) {
      filter['event_type'] = UpperEnums.encodeUpper(eventType);
    }
    return database[_instructionsCollection].findAs(
      (json) => Instruction.fromJson(json),
      filter: filter,
    );
  }
}
