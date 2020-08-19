import 'package:kyaru_bot/kyaru.dart';

void main(List<String> arguments) async {
  var kyaru = Kyaru();
  await kyaru.init();
  await kyaru.start(true);
}
