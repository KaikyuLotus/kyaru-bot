class Avatar {
  final String id;
  final String name;
  final int star;
  final String avatarBackgroundPath;
  final String iconPath;
  final String backgroundPath;
  final String largeBackgroundPath;
  final String figurePath;
  final int level;
  final String obliqueAvatarBackgroundPath;
  final String halfLengthIconPath;
  final String imagePath;

  Avatar(
    this.id,
    this.name,
    this.star,
    this.avatarBackgroundPath,
    this.iconPath,
    this.backgroundPath,
    this.largeBackgroundPath,
    this.figurePath,
    this.level,
    this.obliqueAvatarBackgroundPath,
    this.halfLengthIconPath,
    this.imagePath,
  );

  static Avatar fromJson(Map<String, dynamic> json) {
    return Avatar(
      json['id'],
      json['name'],
      json['star'],
      json['avatar_background_path'],
      json['icon_path'],
      json['background_path'],
      json['large_background_path'],
      json['figure_path'],
      json['level'],
      json['oblique_avatar_background_path'],
      json['half_length_icon_path'],
      json['image_path'],
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'star': star,
      'avatar_background_path': avatarBackgroundPath,
      'icon_path': iconPath,
      'background_path': backgroundPath,
      'large_background_path': largeBackgroundPath,
      'figure_path': figurePath,
      'level': level,
      'oblique_avatar_background_path': obliqueAvatarBackgroundPath,
      'half_length_icon_path': halfLengthIconPath,
      'image_path': imagePath,
    };
  }
}

class Weapon {
  final int id;
  final String name;
  final int maxRarity;
  final int rarity;
  final String icon;

  Weapon(
    this.id,
    this.name,
    this.maxRarity,
    this.rarity,
    this.icon,
  );

  static Weapon fromJson(Map<String, dynamic> json) {
    return Weapon(
      json['id'],
      json['name'],
      json['max_rarity'],
      json['rarity'],
      json['icon'],
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'max_rarity': maxRarity,
      'rarity': rarity,
      'icon': icon,
    };
  }
}

class Stigmata {
  final int id;
  final String name;
  final int maxRarity;
  final int rarity;
  final String icon;

  Stigmata(
    this.id,
    this.name,
    this.maxRarity,
    this.rarity,
    this.icon,
  );

  static Stigmata fromJson(Map<String, dynamic> json) {
    return Stigmata(
      json['id'],
      json['name'],
      json['max_rarity'],
      json['rarity'],
      json['icon'],
    );
  }

  static List<Stigmata> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (i) => Stigmata.fromJson(json[i]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'max_rarity': maxRarity,
      'rarity': rarity,
      'icon': icon,
    };
  }
}

class Character {
  final Avatar avatar;
  final Weapon weapon;
  final List<Stigmata> stigmatas;
  final bool isChosen;

  Character(
    this.avatar,
    this.weapon,
    this.stigmatas,
    this.isChosen,
  );

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      Avatar.fromJson(json['avatar']),
      Weapon.fromJson(json['weapon']),
      Stigmata.listFromJsonArray(json['stigmatas']),
      json['is_chosen'] ?? false,
    );
  }

  static List<Character> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (i) => Character.fromJson(json[i]['character']),
    );
  }

  Map toJson() {
    return {
      'character': {
        'avatar': avatar,
        'weapon': weapon,
        'stigmatas': stigmatas,
        'isChosen': isChosen,
      }
    };
  }
}

class UserCharacters {
  final List<Character> characters;
  UserCharacters(this.characters);

  static UserCharacters fromJson(Map<String, dynamic> json) {
    return UserCharacters(
      Character.listFromJsonArray(json['characters']),
    );
  }

  Map toJson() {
    return {
      'characters': characters,
    };
  }
}

class UserInfo {
  final String avatarUrl;
  final String nickname;
  final String region;
  final int level;

  UserInfo(
    this.avatarUrl,
    this.nickname,
    this.region,
    this.level,
  );

  static UserInfo fromJson(Map<String, dynamic> json) {
    var role = json['role'];
    // var stats = json['stats'];
    // var preference = json['preference'];

    return UserInfo(
      role['AvatarUrl'],
      role['nickname'],
      role['region'],
      role['level'],
    );
  }
}
