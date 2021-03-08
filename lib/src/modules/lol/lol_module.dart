import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/lol_client.dart';

class LoLModule implements IModule {
  final Kyaru _kyaru;
  late LOLClient _client;

  List<ModuleFunction>? _moduleFunctions;

  LoLModule(this._kyaru) {
    _client = LOLClient(_kyaru.kyaruDB.getSettings().lolToken);
    _moduleFunctions = [
      ModuleFunction(getMe, 'Gets user stats from LoL', 'lol', core: true),
    ];
  }

  @override
  List<ModuleFunction>? getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future getMe(Update update, _) async {
    var args = update.message!.text!.split(' ')
      ..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return await _kyaru.reply(update, 'Please specify your username');
    }

    var user = args[0];
    var playIndex = args.length > 1 ? args[1] : '1';
    var playIndexInt = int.tryParse(playIndex);

    if (playIndexInt == null || playIndexInt < 1 || playIndexInt > 100) {
      return await _kyaru.reply(
        update,
        'The third argument must be a number between 1 and 100',
      );
    }

    playIndexInt -= 1;

    var summoner = await _client.getSummoner(user);
    var matches = await _client.getMatches(summoner.accountId);
    var matchInfo = await _client.getMatch(matches[playIndexInt].gameId);
    var summonerIdentity = matchInfo.participantIdentities!.firstWhere(
      (i) => i.player.accountId == summoner.accountId,
    );
    var participant = matchInfo.participants!.firstWhere(
      (p) => p.participantId == summonerIdentity.participantId,
    );
    var usedChampion = _client.findChampionById(
      participant.championId.toString(),
    );

    var durationMinutes = (matchInfo.gameDuration! / 60).floor();
    var durationSeconds =
        (matchInfo.gameDuration! - durationMinutes * 60).floor();

    var kda = '${participant.stats.kills}/'
        '${participant.stats.deaths}/'
        '${participant.stats.assists}';

    var creationDate = matchInfo.gameCreation.toString().split('.')[0];
    var ymd = creationDate.split(' ')[0];
    var y = ymd.split('-')[0];
    var mo = ymd.split('-')[1];
    var d = ymd.split('-')[2];
    ymd = '$d-$mo-$y';
    var hm = creationDate.split(' ')[1];
    var h = hm.split(':')[0];
    var m = hm.split(':')[1];
    hm = '$h:$m';

    var masteries = await _client.getChampionsMasteryBySummonerId(summoner.id);
    var mainChamp =
        _client.findChampionById(masteries.first.championId.toString());

    var firstPart = '*Summoner $user*\nLevel: *${summoner.summonerLevel}*\n'
        'Main champ: *${mainChamp.name}* mastery *${masteries.first.championLevel}*';

    var matchPhrase =
        playIndexInt == 0 ? 'Last match' : 'Match number ${playIndexInt + 1}';

    var message =
        '$firstPart\n\n*$matchPhrase*\nPlayed at *$hm* on the *$ymd* with *${usedChampion.name}*\n'
        '*${matchInfo.gameMode}* - $kda - *${participant.stats.win! ? 'Win' : 'Lost'}*\n'
        'Match lasted $durationMinutes minutes and $durationSeconds seconds';

    await _kyaru.reply(update, message, parseMode: ParseMode.MARKDOWN);
  }
}
