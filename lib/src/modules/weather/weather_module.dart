import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:openweathermap/openweathermap.dart';

import '../../../kyaru.dart';

class WeatherModule implements IModule {
  final Kyaru _kyaru;
  late OpenWeather openWeather;
  String? _key;

  late List<ModuleFunction> _moduleFunctions;

  WeatherModule(this._kyaru) {
    _key = _kyaru.brain.db.settings.weatherToken;
    openWeather = OpenWeather(_key ?? '');
    // TODO: Meteo broadcast
    _moduleFunctions = [
      ModuleFunction(
        weather,
        'Get weather for your city',
        'weather',
        core: true,
      )
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => _key?.isNotEmpty ?? false;

  Future weather(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'This command needs a city as first argument.',
      );
    }

    try {
      var weather = await openWeather.currentWeatherByName(
        args.join(' '),
        units: Units.METRIC,
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
          'The humidity is at ${weather.temperature.humidity}%'
          '\nThe sunrise is at ${sunrise.hour}:${sunrise.minute} '
          'and the sunset is at ${sunset.hour}:${sunset.minute}';

      return _kyaru.reply(
        update,
        message,
      );
    } on Exception {
      return _kyaru.reply(
        update,
        'City not found.',
      );
    }
  }
}
