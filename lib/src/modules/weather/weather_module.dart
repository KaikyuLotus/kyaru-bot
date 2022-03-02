import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:openweathermap/openweathermap.dart';

import '../../../kyaru.dart';
import 'entities/broadcast.dart';

extension on KyaruDB {
  static const _weatherCollection = 'weather';

  List<Broadcast> getCities() {
    return database[_weatherCollection].findAs(Broadcast.fromJson);
  }

  void addCity(Broadcast broadcast) {
    removeCity(broadcast.chatId);
    return database[_weatherCollection].insert(broadcast.toJson());
  }

  bool removeCity(int chatId) {
    return database[_weatherCollection].delete(filter: {'chat_id': chatId});
  }
}

class WeatherModule implements IModule {
  final Kyaru _kyaru;
  late OpenWeather openWeather;
  String? _key;

  late List<ModuleFunction> _moduleFunctions;

  WeatherModule(this._kyaru) {
    _key = _kyaru.brain.db.settings.weatherToken;
    openWeather = OpenWeather(_key ?? '');
    _moduleFunctions = [
      ModuleFunction(
        weather,
        'Get weather for your city',
        'weather',
        core: true,
      ),
      ModuleFunction(
        registerCity,
        'Register your city',
        'registercity',
        core: true,
      ),
      ModuleFunction(
        removeCity,
        'Remove your city',
        'removecity',
        core: true,
      ),
    ];

    if (isEnabled()) {
      startBroadcast();
    }
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => _key?.isNotEmpty ?? false;

  Future<String> weatherMessage(String city) async {
    try {
      var weather = await openWeather.currentWeatherByName(
        city,
        units: Units.metric,
      );

      var sunrise = DateTime.fromMillisecondsSinceEpoch(
          (weather.sunrise + weather.timezone) * 1000);
      var sunset = DateTime.fromMillisecondsSinceEpoch(
          (weather.sunset + weather.timezone) * 1000);
      var temp = weather.temperature.temp;
      var tempFeelsLike = weather.temperature.feelsLike;
      var feelsLike = temp == tempFeelsLike
          ? '.'
          : ', but probably you\'re feeling $tempFeelsLike degrees.';
      var message = 'At ${weather.name} currently there are $temp degrees'
          '$feelsLike\n'
          'The humidity is at ${weather.temperature.humidity}%\n'
          'The sunrise is at ${sunrise.hour}:${sunrise.minute} '
          'and the sunset is at ${sunset.hour}:${sunset.minute}.';

      return message;
    } catch (_) {
      return 'City not found.';
    }
  }

  Future weather(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a city as first argument.',
      );
    }

    var city = args.join(' ');
    var message = await weatherMessage(city);

    return _kyaru.reply(
      update,
      message,
    );
  }

  Future registerCity(Update update, _) async {
    if (update.message!.chat.type != 'private') {
      return _kyaru.reply(
        update,
        'This command works only in private.',
      );
    }

    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a city as first argument.',
      );
    }

    var city = args.join(' ');
    try {
      await openWeather.currentWeatherByName(city);
      var broadcast = Broadcast(
        update.message!.chat.id,
        city,
      );
      _kyaru.brain.db.addCity(broadcast);
      return _kyaru.reply(
        update,
        'City added.',
      );
    } catch (_) {
      return _kyaru.reply(
        update,
        'City not found.',
      );
    }
  }

  Future removeCity(Update update, _) {
    _kyaru.brain.db.removeCity(update.message!.chat.id);
    return _kyaru.reply(update, 'City removed.');
  }

  Future<void> startBroadcast() async {
    Timer.periodic(const Duration(hours: 2), broadcast);
  }

  Future<void> broadcast(Timer? timer) async {
    _kyaru.brain.db.getCities().forEach((b) async {
      var message = await weatherMessage(b.city);
      _kyaru.brain.bot.sendMessage(
        ChatID(b.chatId),
        message,
      );
    });
  }
}
