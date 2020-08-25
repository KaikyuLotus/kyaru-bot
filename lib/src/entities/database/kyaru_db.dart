import 'dart:io';

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
  static const _usageCollection = 'usage_stats';

  Db _db;

  KyaruDB() {
    var host = Platform.environment['MONGO_DART_DRIVER_HOST'] ?? 'mongo';
    var port = Platform.environment['MONGO_DART_DRIVER_PORT'] ?? '27017';
    _db = Db('mongodb://$host:$port/testingphase');
  }

  Future init() async {
    await _db.open();
    await _db.dropCollection(_usageCollection);
  }

  Future<void> addUsageLog() async {
    var now = DateTime.now();
    await _db.collection(_usageCollection).update(
      {'day-hour-minute': '${now.year}-${now.month}-${now.day}T${now.hour}:${now.minute}:00'},
      {'\$inc': {'value': 1}},
      upsert: true,
    );



    // await _db.collection(_usageCollection).insertOne({'timestamp': DateTime.now(), 'value': 1});
  }

  Future<Settings> getSettings() async {
    return Settings.fromJson(await _db.collection(_settingsCollection).findOne());
  }

  Future<void> deleteCustomInstruction(Instruction instruction) async {
    await _db.collection(_instructionsCollection).remove({
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
    _db.collection(_instructionsCollection).insertOne(instruction.toJson());
  }

  void updateChatData(ChatData chatData) {
    _db.collection(_chatDataCollection).update({'id': chatData.id}, chatData.toJson(), upsert: true);
  }

  Future<ChatData> getChatData(int chatId) async {
    return ChatData.fromJson(await _db.collection(_chatDataCollection).findOne({'id': chatId}));
  }

  Future<List<UserSinoAliceData>> getUsersSinoAliceData() async {
    return (await _db.collection(_sinoAliceDataCollection).find().toList()).map(UserSinoAliceData.fromJson).toList();
  }

  Future<UserSinoAliceData> getUserSinoAliceData(int userId) async {
    return UserSinoAliceData.fromJson(await _db.collection(_sinoAliceDataCollection).findOne({'user_id': userId}));
  }

  Future<void> updateUserSinoAliceData(UserSinoAliceData data) async {
    await _db.collection(_sinoAliceDataCollection).update({'user_id': data.userId}, data.toJson(), upsert: true);
  }

  Future<bool> deleteUserSinoAliceData(int userId) async {
    return (await _db.collection(_sinoAliceDataCollection).remove({'user_id': userId})).isNotEmpty;
  }

  // TODO this creates a strict dependency between Kyaru and the github module, find a solution
  Future<List<DBRepo>> getRepos() async {
    return (await _db.collection(_repositoryCollection).find().toList()).map(DBRepo.fromJson).toList();
  }

  Future<void> addRepo(DBRepo repo) async {
    await _db.collection(_repositoryCollection).insertOne(repo.toJson());
  }

  Future<List<Instruction>> getInstructions(InstructionType type, int chatId, {InstructionEventType eventType}) async {
    var filter = {'type': EnumHelper.encode(type), 'chat_id': chatId};
    if (eventType != null) {
      filter['event_type'] = EnumHelper.encode(eventType);
    }
    return (await _db.collection(_instructionsCollection).find(filter).toList()).map(Instruction.fromJson).toList();
  }
}
