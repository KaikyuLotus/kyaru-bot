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
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return true;
  }

  // Admin only
  Future addCredentials(Update update, _) async {
    final parts = update.message!.text!.split('\n');
    parts.removeAt(0);
    if (parts.isEmpty) {
      return _kyaru.reply(
        update,
        'Please send new credentials like this:\n'
        '/add_genshin_cred\n'
        'token: TOKEN\n'
        'uid: UID\n'
        'cn: true/false',
      );
    }
    if (parts.length < 3) {
      return _kyaru.reply(
        update,
        "I didn't find all the required parts",
      );
    }
    Map<String, String> map;
    try {
      map = <String, String>{
        for (var pair in parts.map((e) => e.split(':')))
          pair[0].trim(): pair[1].trim()
      };
    } on RangeError {
      return _kyaru.reply(
        update,
        "Your input contains malformed value pair...",
      );
    }

    final requiredKeys = ['token', 'uid', 'cn'];
    for (final key in requiredKeys) {
      if (!map.containsKey(key)) {
        return _kyaru.reply(
          update,
          "I didn't find '$key' please check your message",
        );
      }
    }

    final token = map['token']!;

    final uid = int.tryParse(map['uid'] ?? '');
    if (uid == null) {
      return _kyaru.reply(
        update,
        "uid is not a valid ID, it's not an integer",
      );
    }

    final cnStr = map['cn']?.toLowerCase();
    if (!['true', 'false'].contains(cnStr)) {
      return _kyaru.reply(
        update,
        "cn is not a valid bool, it's either not 'true' and 'false'",
      );
    }
    final cn = cnStr == 'true';
    final cred = HoyolabCredentials(
      token: token,
      uid: uid,
      isCn: cn,
    );

    if (_credDistrib.exists(token: token)) {
      return _kyaru.reply(
        update,
        "This token is already present!",
      );
    }

    _credDistrib.addCredentials(cred);

    return _kyaru.reply(
      update,
      "Added credentials:\n${JsonEncoder.withIndent('  ').convert(cred)}",
    );
  }
}
