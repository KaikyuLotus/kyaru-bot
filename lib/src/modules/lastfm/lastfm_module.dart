import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/lastfm_client.dart';

extension on KyaruDB {
  static const _lastfmDataCollection = 'lastfm_data';

  void addLastfmUser(int userId, String user) {
    database[_lastfmDataCollection].update(
      {'user_id': userId},
      {'user': user, 'user_id': userId},
      true,
    );
  }

  Map<String, dynamic>? getLastfmUser(int userId) {
    return database[_lastfmDataCollection].findOne(
      filter: {'user_id': userId},
    );
  }
}

class LastfmModule implements IModule {
  final Kyaru _kyaru;
  late LastfmClient lastfmClient;
  String? _key;

  late List<ModuleFunction> _moduleFunctions;

  LastfmModule(this._kyaru) {
    _key = _kyaru.brain.db.settings.lastfmToken;
    lastfmClient = LastfmClient(_key);
    _moduleFunctions = [
      ModuleFunction(
        saveUser,
        'Saves your lastfm user',
        'lastfm_name',
        core: true,
      ),
      ModuleFunction(
        lastTrack,
        'Get last/current song from lastfm',
        'lastfm',
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

  Future saveUser(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a user as first argument',
      );
    }
    var user = args.join(' ');
    try {
      await lastfmClient.getLastTrack(user);
    } on LastfmException {
      return _kyaru.reply(
        update,
        'No user found with that username',
      );
    }
    _kyaru.brain.db.addLastfmUser(update.message!.from!.id, user);

    return _kyaru.reply(
      update,
      'Use /lastfm to get your information!',
    );
  }

  Future lastTrack(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    var user;

    if (args.isEmpty) {
      user = _kyaru.brain.db.getLastfmUser(update.message!.from!.id)?['user'];
      if (user == null) {
        return _kyaru.reply(
          update,
          'This command needs a user as first argument.',
        );
      }
    }
    user ??= args.join(' ');

    try {
      var track = await lastfmClient.getLastTrack(user);
      var imageUrl = MarkdownUtils.generateHiddenUrl(track.imageUrl);
      var userName = MarkdownUtils.escape(update.message!.from!.firstName);
      var title = MarkdownUtils.escape(track.title);
      var artist = MarkdownUtils.escape(track.artist);
      var status = track.nowPlaying ? 'is listening' : 'last listened';

      var message = '$imageUrl*$userName* $status to *$title* by *$artist*';

      return _kyaru.reply(
        update,
        message,
        parseMode: ParseMode.markdownV2,
      );
    } on LastfmException {
      return _kyaru.reply(
        update,
        'No user found with that username',
      );
    }
  }
}
