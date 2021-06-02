import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/steam_client.dart';

class SteamModule implements IModule {
  final Kyaru _kyaru;
  late SteamClient steamClient;
  String? _key;

  late List<ModuleFunction> _moduleFunctions;

  SteamModule(this._kyaru) {
    _key = _kyaru.brain.db.settings.steamToken;
    steamClient = SteamClient(_key);
    _moduleFunctions = [
      ModuleFunction(
        user,
        'steamUser',
        'steam',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() {
    return _key?.isNotEmpty ?? false;
  }

  Future user(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a user as first argument.',
      );
    }
    var user = await steamClient.getUser(args.join(' '));
    var image = MarkdownUtils.generateHiddenUrl(user.avatarFull);
    var url = MarkdownUtils.generateUrl(user.personaName, user.profileUrl);
    var createdDate =
        DateTime.fromMillisecondsSinceEpoch(user.timeCreated * 1000);
    var created = MarkdownUtils.escape(
        '${createdDate.day}/${createdDate.month}/${createdDate.year}');
    var profileState =
        user.communityVisibilityState == 3 ? 'public' : 'private';
    return _kyaru.reply(
      update,
      '$image$url\n\n'
      'This profile is $profileState '
      'and currently ${userStatus(user.profileState)}\n'
      'Created on: $created',
      parseMode: ParseMode.markdownV2,
    );
  }

  String userStatus(int status) {
    var statusMap = {
      0: 'Offline',
      1: 'Online',
      2: 'Busy',
      3: 'Away',
      4: 'Snooze',
      5: 'looking to trade',
      6: 'looking to play',
    };
    return statusMap[status]!;
  }
}
