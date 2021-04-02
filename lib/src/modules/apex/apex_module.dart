import 'dart:async';
import 'dart:typed_data';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:image/image.dart';

import '../../../kyaru.dart';
import 'entities/apex_client.dart';
import 'entities/apex_data.dart';

class ApexModule implements IModule {
  final Kyaru _kyaru;
  late ApexClient _apexClient;

  late List<ModuleFunction> _moduleFunctions;

  ApexModule(this._kyaru) {
    _apexClient = ApexClient(_kyaru.brain.db.settings.apexToken);
    _moduleFunctions = [
      ModuleFunction(
        apex,
        'Returns currents stats for the given player',
        'apex',
        core: true,
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future<Uint8List> setDarkBg(String link) async {
    var banner = decodePng(List.from(await _apexClient.downloadImage(link)))!;
    var canvas = Image(banner.width, banner.height);
    fill(canvas, getColor(39, 39, 39));
    drawImage(canvas, banner);
    return Uint8List.fromList(encodePng(canvas));
  }

  Future apex(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This commands needs an APEX Legends username as first argument.',
      );
    }

    var username = args[0];

    late ApexData data;

    try {
      data = await _apexClient.bridge(username);
    } on ApexException catch (e) {
      if (e.error.contains('Player not found.')) {
        return _kyaru.reply(update, 'Player not found.');
      }
      await _kyaru.reply(update, 'Unknown error while retrieving user.');
      return _kyaru.noticeOwner(update, 'Apex command error: ${e.error}');
    }

    if ([data.global, data.realtime, data.legends].contains(null)) {
      return _kyaru.reply(update, 'Some information is missing, sorry.');
    }

    var rank = MarkdownUtils.escape(data.global!.rank.rankName);

    var status = 'This user is currently *offline*';
    if (data.realtime?.isOnline ?? false) {
      status = 'This user is *online*';
    }
    if (data.realtime?.isInGame ?? false) {
      status = 'This user is currently *in a match*';
    }

    var hiddenLink = '';
    var legend = MarkdownUtils.escape(data.legends!.selected.legendName);

    var currentPercentage = 100 - data.global!.toNextLevelPercent;

    var reply =
        '$hiddenLink*$username \\- $rank ${data.global!.rank.rankDiv}*\n'
        'Level *${data.global!.level}* \\'
        '(*$currentPercentage%* until next level\\)\n'
        'Current legend: *$legend*\n'
        '\n$status';

    var editedImage = await setDarkBg(data.legends!.selected.imgAssets.icon!);

    await _kyaru.replyPhoto(
      update,
      HttpFile.fromBytes('banner.jpg', editedImage),
      caption: reply,
      parseMode: ParseMode.MARKDOWNV2,
    );
  }
}
