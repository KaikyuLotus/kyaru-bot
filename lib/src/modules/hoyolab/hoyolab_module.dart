import 'dart:convert';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'components/credentials_distributor.dart';

class HoyolabModule implements IModule {
  final Kyaru _kyaru;
  late CredentialsDistributor _credDistrib;

  late List<ModuleFunction> _moduleFunctions;

  HoyolabModule(this._kyaru) {
    _credDistrib = CredentialsDistributor.withDatabase(_kyaru.brain.db);

    _moduleFunctions = [
      ModuleFunction(
        addCredentials,
        'Owner only command that adds Hoyolab credentials',
        'add_hoyolab_cred',
      ),
      ModuleFunction(
        addUserCredentials,
        'Command that adds Hoyolab credentials',
        'hoyolab_cred',
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return true;
  }

  Future<HoyolabCredentials?> checkCred(
    Update update, {
    bool user = false,
  }) async {
    final parts = update.message!.text!.split('\n');
    parts.removeAt(0);
    if (parts.isEmpty) {
      var command = user ? '/hoyolab_cred' : '/add_hoyolab_cred';
      _kyaru.reply(
        update,
        'Please send new credentials like this:\n'
        '$command\n'
        'token: TOKEN\n'
        'uid: UID\n'
        'cn: true/false',
      );
      return null;
    }
    if (parts.length < 3) {
      _kyaru.reply(
        update,
        "I didn't find all the required parts",
      );
      return null;
    }
    Map<String, String> map;
    try {
      map = <String, String>{
        for (var pair in parts.map((e) => e.split(':')))
          pair[0].trim(): pair[1].trim()
      };
    } on RangeError {
      _kyaru.reply(
        update,
        "Your input contains malformed value pair...",
      );
      return null;
    }

    final requiredKeys = ['token', 'uid', 'cn'];
    for (final key in requiredKeys) {
      if (!map.containsKey(key)) {
        _kyaru.reply(
          update,
          "I didn't find '$key' please check your message",
        );
        return null;
      }
    }

    final token = map['token']!;

    final uid = int.tryParse(map['uid'] ?? '');
    if (uid == null) {
      _kyaru.reply(
        update,
        "uid is not a valid ID, it's not an integer",
      );
      return null;
    }

    final cnStr = map['cn']?.toLowerCase();
    if (!['true', 'false'].contains(cnStr)) {
      _kyaru.reply(
        update,
        "cn is not a valid bool, it's either not 'true' and 'false'",
      );
      return null;
    }
    final cn = cnStr == 'true';
    final userId = update.message!.from!.id;
    final cred = HoyolabCredentials(
      token: token,
      uid: uid,
      userId: user ? userId : 0,
      isCn: cn,
    );

    if (_credDistrib.exists(token: token, user: user)) {
      _kyaru.reply(
        update,
        "This token is already present!",
      );
      return null;
    }
    return cred;
  }

  // Admin only
  Future addCredentials(Update update, _) async {
    var cred = await checkCred(update);

    if (cred != null) {
      _credDistrib.addCredentials(cred);

      return _kyaru.reply(
        update,
        "Added credentials:\n${JsonEncoder.withIndent('  ').convert(cred)}",
      );
    }
  }

  Future addUserCredentials(Update update, _) async {
    var cred = await checkCred(update, user: true);

    if (cred != null) {
      _credDistrib.addUserCredentials(cred);

      return _kyaru.reply(
        update,
        "Added credentials:\n${JsonEncoder.withIndent('  ').convert(cred)}",
      );
    }
  }
}
