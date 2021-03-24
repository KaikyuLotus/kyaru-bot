import 'package:kyaru_bot/kyaru.dart';
import 'package:logging/logging.dart';

void main(List<String> arguments) async {

  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.time}: [\x1B[35m${record.loggerName}\x1B[0m] >> ${record.message}' +
        (record.error != null ? ': ${record.error}' : ''));
    if (record.stackTrace != null) {
      print('${record.stackTrace}');
    }
  });

  Future onReady(Kyaru kyaru) async {
    var modules = <IModule>[
      RegexModule(kyaru),
      OwnerModule(kyaru),
      AdminsModule(kyaru),
      LoLModule(kyaru),
      InsultsModule(kyaru),
      DanbooruModule(kyaru),
      YandereModule(kyaru),
      JikanModule(kyaru),
      ApexModule(kyaru),
      // (Kyaru kyaru) => GenshinModule(kyaru),
    ];

    kyaru.useModules(modules);

    kyaru.start();
  }

  Kyaru(onReady: onReady);
}
