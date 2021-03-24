import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';

class RegexModule implements IModule {
  final Kyaru _kyaru;
  List<ModuleFunction>? _moduleFunctions;

  RegexModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(regexReplace, 'asd', 'regexReplace'), // public: false
    ];
  }

  @override
  List<ModuleFunction>? get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future regexReplace(Update update, _) async {
    var text = update.message!.text!;
    var quotedText = update.message!.replyToMessage!.text!;

    var regex = RegExp('s/(.+)/(.+)');
    var match = regex.firstMatch(text)!;
    var first = match.group(1)!;
    var second = match.group(2)!;

    var fixed = quotedText.replaceAll(first, second);

    if (fixed == quotedText) {
      return;
    }

    var reply = '"$fixed"\n\nFixed!';
    await _kyaru.brain.bot.sendMessage(
      ChatID(update.message!.chat.id),
      reply,
      replyToMessageId: update.message?.replyToMessage?.messageId,
    );
  }
}
