import 'dart:io';

import 'package:dart_mongo_lite/dart_mongo_lite.dart';
import 'package:kyaru_bot/src/modules/github/entities/db/db_repo.dart';
import 'package:kyaru_bot/src/modules/sinoalice/entities/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../kyaru.dart';
import '../instruction.dart';
import '../settings.dart';

class KyaruDB {
  static const _settingsCollection = 'settings';
  static const _instructionsCollection = 'instructions';
  static const _repositoryCollection = 'repositories';
  static const _chatDataCollection = 'chat_data';
  static const _sinoAliceDataCollection = 'sinoalice_data';

  final Database _database = Database('database/database.json');

  Db _db;

  KyaruDB() {
    var host = Platform.environment['MONGO_DART_DRIVER_HOST'] ?? 'mongo';
    var port = Platform.environment['MONGO_DART_DRIVER_PORT'] ?? '27017';
    _db = Db('mongodb://$host:$port/testingphase');
  }

  Future init() async {
    await _db.open();
  }

  Future<Settings> getSettings() async {
    return Settings.fromJson(await _db.collection(_settingsCollection).findOne());
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
    _database[_chatDataCollection].update({'id': chatData.id}, chatData.toJson(), true);
  }

  ChatData getChatData(int chatId) {
    return _database[_chatDataCollection].findOneAs((json) => ChatData.fromJson(json), filter: {'id': chatId});
  }

  List<UserSinoAliceData> getUsersSinoAliceData() {
    return _database[_sinoAliceDataCollection].findAs((json) => UserSinoAliceData.fromJson(json));
  }

  UserSinoAliceData getUserSinoAliceData(int userId) {
    return _database[_sinoAliceDataCollection]
        .findOneAs((json) => UserSinoAliceData.fromJson(json), filter: {'user_id': userId});
  }

  void updateUserSinoAliceData(UserSinoAliceData data) {
    _database[_sinoAliceDataCollection].update({'user_id': data.userId}, data.toJson(), true);
  }

  bool deleteUserSinoAliceData(int userId) {
    return _database[_sinoAliceDataCollection].delete({'user_id': userId});
  }

  // TODO this creates a strict dependency between Kyaru and the github module, find a solution
  List<DBRepo> getRepos() {
    return _database[_repositoryCollection].findAs((r) => DBRepo.fromJson(r));
  }

  void addRepo(DBRepo repo) {
    return _database[_repositoryCollection].insert(repo.toJson());
  }

  List<Instruction> getInstructions(InstructionType type, int chatId, {InstructionEventType eventType}) {
    var filter = {'type': EnumHelper.encode(type), 'chat_id': chatId};
    if (eventType != null) {
      filter['event_type'] = EnumHelper.encode(eventType);
    }
    return _database[_instructionsCollection].findAs((json) => Instruction.fromJson(json), filter: filter);
  }
}
