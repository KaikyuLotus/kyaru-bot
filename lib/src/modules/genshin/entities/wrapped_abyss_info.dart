import 'package:dart_telegram_bot/telegram_entities.dart';

import 'abyss_info.dart';

class WrappedAbyssInfo {
  final Message sentMessage;
  final double cacheTime;
  final AbyssInfo current;
  final AbyssInfo previous;

  WrappedAbyssInfo({
    required this.sentMessage,
    required this.cacheTime,
    required this.current,
    required this.previous,
  });
}
