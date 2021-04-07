import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/lastfm_client.dart';

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

  Future lastTrack(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a user as first argument.',
      );
    }

    try {
      var track = await lastfmClient.getLastTrack(args.join(' '));
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
