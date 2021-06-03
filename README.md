# Kyaru [![Dart CI/CD](https://github.com/KaikyuLotus/kyaru-bot/actions/workflows/dart-dev.yml/badge.svg)](https://github.com/KaikyuLotus/kyaru-bot/actions/workflows/dart-dev.yml) [![Telegram Bot](https://img.shields.io/badge/Telegram%20Bot-@KiruyaBot-blue.svg?style=flat)](https://t.me/KiruyaBot) [![Telegram Channel](https://img.shields.io/badge/Telegram%20Channel-@Kaikyu-blue.svg?style=flat)](https://t.me/kaikyu)

Kyaru is an utility bot made mainly for groups.

## Settings (database/database.json)
```json
{
    "settings": [
        {
            "token": "String",
            "lol_token": "String",
            "lastfm_token": "String",
            "weather_token": "String",
            "steam_token": "String",
            "videogame_token": "String",
            "genshin_url": "String",
            "owner_id": "int"
        }
    ]
}
```

All fields, except the token and the owner_id, can be empty or omitted.

`token`: Telegram bot token, obtainable [here](https://t.me/BotFather)<br>
`lol_token`: Riot api key, obtainable [here](https://developer.riotgames.com/)<br>
`apex_token`: obtainable [here](https://apexlegendsapi.com/documentation.php)<br>
`lastfm_token`: LastFM api key, obtainable [here](https://www.last.fm/api)<br>
`weather_token`: OpenWeather api key, obtainable [here](https://openweathermap.org/api)<br>
`steam_token`: Steam api key, obtainable [here](https://steamcommunity.com/dev/apikey)<br>
`videogame_token`: RAWG api key, obtainable [here](https://rawg.io/apidocs)<br>
`genshin_url`<br>
`owner_id`: Your telegram id<br>