import 'package:dart_mongo_lite/dart_mongo_lite.dart';
import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:kyaru_bot/src/modules/github/entities/db/db_repo.dart';
import 'package:kyaru_bot/src/modules/sinoalice/entities/user.dart';

import '../../../kyaru.dart';
import '../instruction.dart';
import '../settings.dart';

class KyaruDB {
  static const _settingsCollection = 'settings';
  static const _instructionsCollection = 'instructions';
  static const _repositoryCollection = 'repositories';
  static const _chatDataCollection = 'chat_data';
  static const _sinoAliceDataCollection = 'sinoalice_data';
  static const _genshinDataCollection = 'genshin_data';

  final Database _database = Database('database/database.json');

  Settings getSettings() {
    return _database[_settingsCollection].findOneAs(
      (json) => Settings.fromJson(json),
    )!;
  }

  void deleteCustomInstruction(Instruction instruction) {
    _database[_instructionsCollection].delete({
      'uuid': instruction.uuid,
      'chat_id': instruction.chatId,
      'type': EnumHelper.encode(instruction.instructionType),
      'event_type': EnumHelper.encode(instruction.instructionEventType),
      'function': instruction.function,
      'regex': instruction.regex,
      'require_quote': instruction.requireQuote,
    });
  }

  void addCustomInstruction(Instruction instruction) {
    _database[_instructionsCollection].insert(instruction.toJson());
  }

  void updateChatData(ChatData chatData) {
    _database[_chatDataCollection].update(
      {'id': chatData.id},
      chatData.toJson(),
      true,
    );
  }

  ChatData? getChatData(int chatId) {
    return _database[_chatDataCollection].findOneAs(
      (json) => ChatData.fromJson(json),
      filter: {'id': chatId},
    );
  }

  List<UserSinoAliceData> getUsersSinoAliceData() {
    return _database[_sinoAliceDataCollection].findAs(
      (json) => UserSinoAliceData.fromJson(json),
    );
  }

  UserSinoAliceData? getUserSinoAliceData(int userId) {
    return _database[_sinoAliceDataCollection].findOneAs(
      (json) => UserSinoAliceData.fromJson(json),
      filter: {'user_id': userId},
    );
  }

  void updateUserSinoAliceData(UserSinoAliceData data) {
    _database[_sinoAliceDataCollection].update(
      {'user_id': data.userId},
      data.toJson(),
      true,
    );
  }

  bool deleteUserSinoAliceData(int userId) {
    return _database[_sinoAliceDataCollection].delete(
      {'user_id': userId},
    );
  }

  // TODO this creates a strict dependency between Kyaru and the github module, find a solution
  List<DBRepo> getRepos() {
    return _database[_repositoryCollection].findAs((r) => DBRepo.fromJson(r));
  }

  void addRepo(DBRepo repo) {
    return _database[_repositoryCollection].insert(repo.toJson());
  }

  void addGenshinUser(int userId, int id) {
    _database[_genshinDataCollection]
        .update({'user_id': userId}, {'id': id, 'user_id': userId}, true);
  }

  Map<String, dynamic>? getGenshinUser(int userId) {
    return _database[_genshinDataCollection].findOne(
      filter: {'user_id': userId},
    );
  }

  List<Instruction> getInstructions(
    InstructionType type,
    int chatId, {
    InstructionEventType? eventType,
  }) {
    var filter = {'type': EnumHelper.encode(type), 'chat_id': chatId};
    if (eventType != null) {
      filter['event_type'] = EnumHelper.encode(eventType);
    }
    return _database[_instructionsCollection].findAs(
      (json) => Instruction.fromJson(json),
      filter: filter,
    );
  }
}
