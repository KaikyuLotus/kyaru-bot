import 'package:kyaru_bot/kyaru.dart';

void main(List<String> arguments) async {
  var db = KyaruDB();
  await db.init();
  var kyaru = Kyaru(db, (await db.getSettings()).token);
  await kyaru.init();
  await kyaru.start(true);
}
