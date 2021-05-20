import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/lol_client.dart';

class LoLModule implements IModule {
  final Kyaru _kyaru;
  late LOLClient _client;
  String? _key;

  late List<ModuleFunction> _moduleFunctions;

  LoLModule(this._kyaru) {
    _key = _kyaru.brain.db.settings.lolToken;
    _client = LOLClient(_key);
    _moduleFunctions = [
      ModuleFunction(
        getMe,
        'Gets user stats from LoL',
        'lol',
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

  Future getMe(Update update, _) async {
    var args = update.message!.text!.split(' ')
      ..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return _kyaru.reply(update, 'Please specify your username');
    }

    var user = args[0];
    var playIndex = args.length > 1 ? args[1] : '1';
    var playIndexInt = int.tryParse(playIndex);

    if (playIndexInt == null || playIndexInt < 1 || playIndexInt > 100) {
      return _kyaru.reply(
        update,
        'The third argument must be a number between 1 and 100',
      );
    }

    playIndexInt -= 1;

    var summoner = await _client.getSummoner(user);

    if (summoner == null) {
      return _kyaru.reply(update, 'Player not found.');
    }

    var matches = await _client.getMatches(summoner.accountId);
    if (matches.isEmpty) {
      return _kyaru.reply(update, 'Player has no recent matches.');
    }

    if (playIndexInt > matches.length - 1) {
      return _kyaru.reply(
        update,
        'Given match not found, maximum match index found is ${matches.length}',
      );
    }

    var selectedGameId = matches[playIndexInt].gameId;

    var matchInfo = await _client.getMatch(selectedGameId);

    var summonerIdentity = matchInfo.participantIdentities.firstWhere(
      (i) => i.player.accountId == summoner.accountId,
    );

    var participant = matchInfo.participants.firstWhere(
      (p) => p.participantId == summonerIdentity.participantId,
    );

    var masteries = await _client.getChampionsMasteryBySummonerId(summoner.id);

    var mainChamp = _client.findChampionById('${masteries.first.championId}');
    var usedChampion = _client.findChampionById('${participant.championId}');

    if (usedChampion == null || mainChamp == null) {
      await _kyaru.reply(update, "It seems i can't get a champion used.");
      return _kyaru.noticeOwner(update, 'Master, update LoL characters!');
    }

    var durationMinutes = matchInfo.gameDuration ~/ 60;
    var durationSeconds = matchInfo.gameDuration.remainder(60);

    var kda = '${participant.stats.kills}/'
        '${participant.stats.deaths}/'
        '${participant.stats.assists}';

    var creationDate = '${matchInfo.gameCreation}'.split('.')[0];
    var ymd = creationDate.split(' ')[0];
    var y = ymd.split('-')[0];
    var mo = ymd.split('-')[1];
    var d = ymd.split('-')[2];
    ymd = '$d-$mo-$y';
    var hm = creationDate.split(' ')[1];
    var h = hm.split(':')[0];
    var m = hm.split(':')[1];
    hm = '$h:$m';

    var firstPart = '*Summoner $user*\n'
        'Level: *${summoner.summonerLevel}*\n'
        'Main champ: *${mainChamp.name}*'
        ' mastery *${masteries.first.championLevel}*';

    var matchPhrase =
        playIndexInt == 0 ? 'Last match' : 'Match number ${playIndexInt + 1}';

    var message = '$firstPart\n\n*$matchPhrase*\nPlayed'
        ' at *$hm* on the *$ymd* with *${usedChampion.name}*\n'
        '*${matchInfo.gameMode}* - $kda -'
        ' *${participant.stats.win! ? 'Win' : 'Lost'}*\n'
        'Match lasted $durationMinutes minutes and $durationSeconds seconds';

    return _kyaru.reply(update, message, parseMode: ParseMode.markdown);
  }
}
