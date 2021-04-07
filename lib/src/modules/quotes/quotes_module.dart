import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/quotes_client.dart';

class QuotesModule implements IModule {
  final Kyaru _kyaru;
  final QuotesClient quotesClient = QuotesClient();

  late List<ModuleFunction> _moduleFunctions;

  QuotesModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        quote,
        'Sends a random anime quote',
        'quote',
        core: true,
      )
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future quote(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return randomQuote(update);
    }

    var specifiedMode = args.removeAt(0).toLowerCase();

    var modeList = {'anime': 'title', 'character': 'name'};

    if (!modeList.containsKey(specifiedMode)) {
      return _kyaru.reply(update, 'Specified mode not recognized');
    }

    if (args.isEmpty) {
      return randomQuote(update);
    }

    return getQuote(
      update: update,
      mode: specifiedMode,
      search: modeList[specifiedMode]!,
      query: args.join(' '),
    );
  }

  Future randomQuote(Update update) async {
    var quote = await quotesClient.getRandomQuote();
    return _kyaru.reply(
        update,
        '_${MarkdownUtils.escape(quote.quote)}_\n\n'
        '\\- ${MarkdownUtils.escape('${quote.character}, ${quote.anime}')}',
        parseMode: ParseMode.markdownV2);
  }

  Future getQuote({
    required Update update,
    required String mode,
    required String search,
    required String query,
  }) async {
    try {
      var result = await quotesClient.getQuotes(
        mode: mode,
        parameters: {
          search: query,
        },
      );
      result.shuffle();
      var quote = result[0];
      return _kyaru.reply(
          update,
          '_${MarkdownUtils.escape(quote.quote)}_\n\n'
          '\\- ${MarkdownUtils.escape('${quote.character}, ${quote.anime}')}',
          parseMode: ParseMode.markdownV2);
    } on NotFound {
      return _kyaru.reply(update, 'No quote found from that $mode');
    }
  }
}
