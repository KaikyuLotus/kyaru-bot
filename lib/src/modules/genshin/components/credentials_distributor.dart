import 'dart:convert';

import 'package:kyaru_bot/kyaru.dart';
import 'package:logging/logging.dart';

extension on KyaruDB {
  static const collection = 'hoyolab_credentials';

  // Credentials
  void addCredential(HoyolabCredentials credentials) {
    database[collection].insert(json.decode(json.encode(credentials)));
  }

  List<HoyolabCredentials> getAllCredentials() {
    return database[collection].findAs(HoyolabCredentials.fromJson);
  }

  HoyolabCredentials lessUsedCredentials() {
    final creds = database[collection] //
        .findAs(HoyolabCredentials.fromJson) //
      ..sort((a, b) => a.gameIds.length.compareTo(b.gameIds.length));
    return creds.first;
  }

  HoyolabCredentials? credentialsForUser(int gameId) {
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

  HoyolabCredentials? credentialsWithToken(String token) {
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
  late final List<int> gameIds;

  HoyolabCredentials({
    required this.token,
    required this.uid,
    this.isCn = false,
    List<int>? ids,
  }) : gameIds = ids ?? <int>[];

  static HoyolabCredentials fromJson(Map<String, dynamic> json) {
    return HoyolabCredentials(
      token: json['token'],
      uid: json['uid'],
      isCn: json['cn'] ?? false,
      ids: List<int>.from(json['game_ids'] ?? <int>[]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'uid': uid,
      'cn': isCn,
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

  bool exists({required String token}) {
    return db.credentialsWithToken(token) != null;
  }

  HoyolabCredentials forUser(int gameId) {
    final credentials = db.credentialsForUser(gameId);
    if (credentials != null) {
      return credentials;
    }

    final lessUsedCred = db.lessUsedCredentials();
    lessUsedCred.gameIds.add(gameId);
    db.updateCredentials(lessUsedCred);
    return lessUsedCred;
  }
}
