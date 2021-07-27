import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:kyaru_bot/src/modules/genshin/entities/userinfo.dart';

class WrappedUserInfo {
  final Message sentMessage;
  final double cacheTime;
  final UserInfo userInfo;

  WrappedUserInfo({
    required this.sentMessage,
    required this.cacheTime,
    required this.userInfo,
  });
}
