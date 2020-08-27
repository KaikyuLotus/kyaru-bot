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
  static const _pingsCollection = 'pings';

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

  Future<void> addPing(int ping) async {
    await _db.collection(_pingsCollection).insertOne({'ts': DateTime.now(), 'time': ping});
  }

  Future<void> addUsageLog() async {
    var now = DateTime.now();
    await _db.collection(_usageCollection).update(
      {'day-hour-minute': '${now.year}-${now.month}-${now.day}T${now.hour}:${now.minute}:00'},
      {
        '\$inc': {'value': 1}
      },
      upsert: true,
    );
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

  Future<void> updateCustomInstruction(Instruction instruction) async {
    await _db.collection(_instructionsCollection).update({'uuid': instruction.uuid}, instruction.toJson(), upsert: true);
  }

  Future<void> addCustomInstruction(Instruction instruction) async {
    await _db.collection(_instructionsCollection).insertOne(instruction.toJson());
  }

  Future<void> updateChatData(ChatData chatData) async {
    await _db.collection(_chatDataCollection).update({'id': chatData.id}, chatData.toJson(), upsert: true);
  }

  Future<void> addChatData(List<ChatData> chatData) async {
    await _db.collection(_chatDataCollection).insertAll(chatData.map((e) => e.toJson()).toList());
  }

  Future<ChatData> getChatData(int chatId) async {
    return ChatData.fromJson(await _db.collection(_chatDataCollection).findOne({'id': chatId}));
  }

  Future<List<ChatData>> getChatsData() async {
    return ChatData.listFromJsonArray(await (_db.collection(_chatDataCollection).find().toList()));
  }

  Future<List<UserSinoAliceData>> getUsersSinoAliceData() async {
    return UserSinoAliceData.listFromJsonArray(await _db.collection(_sinoAliceDataCollection).find().toList());
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
    return DBRepo.listFromJsonArray(await _db.collection(_repositoryCollection).find().toList());
  }

  Future<void> addRepo(DBRepo repo) async {
    await _db.collection(_repositoryCollection).insertOne(repo.toJson());
  }

  Future<List<Instruction>> getInstructions({InstructionType type, int chatId, InstructionEventType eventType}) async {
    var filter = <String, dynamic>{};
    if (type != null) {
      filter['type'] = EnumHelper.encode(type);
    }
    if (chatId != null) {
      filter['chat_id'] = chatId;
    }
    if (eventType != null) {
      filter['event_type'] = EnumHelper.encode(eventType);
    }
    return Instruction.listFromJsonArray(await _db.collection(_instructionsCollection).find(filter).toList());
  }
}
