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
        'Sends a random quote',
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
    var quote = await quotesClient.getQuote();
    return _kyaru.reply(
      update,
      '${quote.quote}\n\n- ${quote.character}',
    );
  }
}
