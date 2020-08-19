import 'dart:async';
import 'dart:typed_data';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:image/image.dart';

import '../../../kyaru.dart';
import 'entities/apex_client.dart';

class ApexModule implements IModule {
  final Kyaru _kyaru;
  ApexClient _apexClient;

  List<ModuleFunction> _moduleFunctions;

  ApexModule(this._kyaru) {
    _apexClient = ApexClient(_kyaru.kyaruDB.getSettings().apexToken);
    _moduleFunctions = [
      ModuleFunction(apex, 'Returns currents stats for the given player', 'apex', core: true),
    ];
  }

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future<Uint8List> setDarkBg(String link) async {
    var banner = decodePng(List.from(await _apexClient.downloadImage(link)));
    var canvas = Image(banner.width, banner.height);
    fill(canvas, getColor(39, 39, 39));
    drawImage(canvas, banner);
    return Uint8List.fromList(encodePng(canvas));
  }

  Future apex(Update update, Instruction instruction) async {
    var args = update.message.text.split(' ')..removeAt(0);
    if (args.isEmpty) {
      return await _kyaru.reply(update, 'This commands needs an APEX Legends username as first argument.');
    }

    var username = args[0];

    var apexData = await _apexClient.bridge(username);

    if (apexData == null) {
      return await _kyaru.reply(update, 'Something went fucking wrong...');
    }

    if (apexData.error != null) {
      return await _kyaru.reply(update, 'Probably the given player does not exist'); // TODO check real error
    }

    var rank = MarkdownUtils.escape(apexData.global.rank.rankName);

    var status = 'This user is currently *offline*';
    if (apexData.realtime.isOnline) {
      status = 'This user is *online*';
    }
    if (apexData.realtime.isInGame) {
      status = 'This user is currently *in a match*';
    }

    var hiddenLink = ''; // MarkdownUtils.generateHiddenUrl(apexData.legends.selected.imgAssets.icon);
    var legend = MarkdownUtils.escape(apexData.legends.selected.legendName);

    var reply = '$hiddenLink*$username \\- $rank ${apexData.global.rank.rankDiv}*\n'
        'Level *${apexData.global.level}* \\(*${apexData.global.toNextLevelPercent}%* until next level\\)\n'
        'Current legend: *$legend*\n'
        '\n$status';

    var editedImage = await setDarkBg(apexData.legends.selected.imgAssets.icon);

    await _kyaru.replyPhoto(
      update,
      HttpFile.fromBytes('banner.jpg', editedImage),
      caption: reply,
      parseMode: ParseMode.MarkdownV2(),
    );
  }
}
