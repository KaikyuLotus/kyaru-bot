import 'dart:convert';

import 'package:logging/logging.dart';

import '../../../../kyaru.dart';

extension on KyaruDB {
  static const collection = 'hoyolab_credentials';
  static const userCollection = 'hoyolab_user_credentials';

  // Credentials
  void addCredential(HoyolabCredentials credentials) {
    database[collection].insert(json.decode(json.encode(credentials)));
  }

  void addUserCredential(HoyolabCredentials credentials) {
    database[userCollection].insert(json.decode(json.encode(credentials)));
  }

  List<HoyolabCredentials> getAllCredentials() {
    return database[collection].findAs(HoyolabCredentials.fromJson);
  }

  HoyolabCredentials lessUsedCredentials({bool cn = false}) {
    final creds = database[collection] //
        .findAs(HoyolabCredentials.fromJson) //
        .where((c) => c.isCn == cn)
        .toList();
    creds.sort((a, b) => a.gameIds.length.compareTo(b.gameIds.length));
    return creds.first;
  }

  HoyolabCredentials? credentialsForUser(int userId, int gameId) {
    var userCred = database[userCollection].findOneAs(
      HoyolabCredentials.fromJson,
      callback: (c) => c['user_id'] == userId,
    );
    if (userCred != null) {
      return userCred;
    }
    return database[collection].findOneAs(
      HoyolabCredentials.fromJson,
      callback: (c) => c['game_ids'].contains(gameId),
    );
  }

  void updateCredentials(HoyolabCredentials credentials) {
    database[collection].update(
      {'token': credentials.token},
      credentials.toJson(),
    );
  }

  HoyolabCredentials? credentialsWithToken(String token, bool user) {
    if (user) {
      return database[userCollection].findOneAs(
        HoyolabCredentials.fromJson,
        filter: {'token': token},
      );
    }
    return database[collection].findOneAs(
      HoyolabCredentials.fromJson,
      filter: {'token': token},
    );
  }
}

class HoyolabCredentials {
  final String token;
  final int uid;
  final bool isCn;
  final int userId;
  late final List<int> gameIds;

  HoyolabCredentials({
    required this.token,
    required this.uid,
    this.isCn = false,
    this.userId = 0,
    List<int>? ids,
  }) : gameIds = ids ?? <int>[];

  static HoyolabCredentials fromJson(Map<String, dynamic> json) {
    return HoyolabCredentials(
      token: json['token'],
      uid: json['uid'],
      isCn: json['cn'] ?? false,
      userId: json['user_id'] ?? 0,
      ids: List<int>.from(json['game_ids'] ?? <int>[]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'uid': uid,
      'cn': isCn,
      'user_id': userId,
      'game_ids': gameIds,
    };
  }
}

class CredentialsDistributor {
  final logger = Logger('CredentialsDistributor');

  final KyaruDB db;

  CredentialsDistributor.withDatabase(this.db);

  bool get hasCredentials => db.getAllCredentials().isNotEmpty;

  void addCredentials(HoyolabCredentials credentials) {
    db.addCredential(credentials);
  }

  void addUserCredentials(HoyolabCredentials credentials) {
    db.addUserCredential(credentials);
  }

  bool exists({required String token, bool user = false}) {
    return db.credentialsWithToken(token, user) != null;
  }

  HoyolabCredentials forUser(int userId, int gameId, bool chinese) {
    final credentials = db.credentialsForUser(userId, gameId);
    if (credentials != null) {
      return credentials;
    }

    final lessUsedCred = db.lessUsedCredentials(cn: chinese);
    lessUsedCred.gameIds.add(gameId);
    db.updateCredentials(lessUsedCred);
    return lessUsedCred;
  }
}
