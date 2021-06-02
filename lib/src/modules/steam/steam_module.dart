import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/steam_client.dart';
import 'entities/util.dart';

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
        'Get your profile info',
        'steam',
        core: true,
      ),
      ModuleFunction(
        group,
        'Get steam group info',
        'steamgroup',
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
    try {
      var user = await steamClient.getUser(args.join(' '));
      var image = MarkdownUtils.generateHiddenUrl(user.avatarFull);
      var url = MarkdownUtils.generateUrl(user.personaName, user.profileUrl);
      var createdDate =
          DateTime.fromMillisecondsSinceEpoch(user.timeCreated * 1000);
      var created = MarkdownUtils.escape(
          '${createdDate.day}/${createdDate.month}/${createdDate.year}');
      var profileState =
          user.communityVisibilityState == 3 ? 'public' : 'private';
      var clan = MarkdownUtils.escape(
          '${user.primaryClanId} (use /steamgroup for more info)');
      return _kyaru.reply(
        update,
        '$image$url\n\n'
        'This profile is $profileState '
        'and currently ${userStatus(user.profileState)}\n'
        'Created on: $created\n'
        'Main group: $clan',
        parseMode: ParseMode.markdownV2,
      );
    } on Exception {
      return _kyaru.reply(update, 'User not found.');
    }
  }

  Future group(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a group id as first argument.',
      );
    }
    try {
      var group = await steamClient.getGroup(args.join(' '));

      var image = MarkdownUtils.generateHiddenUrl(group.avatarFull);
      var name = MarkdownUtils.escape(group.name);
      var summary = MarkdownUtils.escape(removeAllHtmlTags(group.summary));
      return _kyaru.reply(
        update,
        '$image$name\n\n'
        '$summary\n\n'
        'Member count: ${group.memberCount}\n'
        'Members online: ${group.membersOnline}\n'
        'Members in chat: ${group.membersInChat}\n'
        'Members in game: ${group.membersInGame}\n',
        parseMode: ParseMode.markdownV2,
      );
    } on Exception {
      return _kyaru.reply(update, 'Group not found.');
    }
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
