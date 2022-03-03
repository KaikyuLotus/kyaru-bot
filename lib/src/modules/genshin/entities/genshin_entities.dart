import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../../kyaru.dart';
import '../../hoyolab/entities/api_cache.dart';

class AbyssInfo {
  final int scheduleId;
  final String startTime;
  final String endTime;
  final int totalBattleTimes;
  final int totalWinTimes;
  final String maxFloor;
  final List<Rank> revealRank;
  final List<Rank> defeatRank;
  final List<Rank> damageRank;
  final List<Rank> takeDamageRank;
  final List<Rank> normalSkillRank;
  final List<Rank> energySkillRank;
  final List<Floor> floors;
  final int totalStar;
  final bool isUnlock;

  AbyssInfo({
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.totalBattleTimes,
    required this.totalWinTimes,
    required this.maxFloor,
    required this.revealRank,
    required this.defeatRank,
    required this.damageRank,
    required this.takeDamageRank,
    required this.normalSkillRank,
    required this.energySkillRank,
    required this.floors,
    required this.totalStar,
    required this.isUnlock,
  });

  static AbyssInfo fromJson(Map<String, dynamic> json) {
    return AbyssInfo(
      scheduleId: json['schedule_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalBattleTimes: json['total_battle_times'],
      totalWinTimes: json['total_win_times'],
      maxFloor: json['max_floor'],
      revealRank: Rank.listFromJsonArray(json['reveal_rank']),
      defeatRank: Rank.listFromJsonArray(json['defeat_rank']),
      damageRank: Rank.listFromJsonArray(json['damage_rank']),
      takeDamageRank: Rank.listFromJsonArray(json['take_damage_rank']),
      normalSkillRank: Rank.listFromJsonArray(json['normal_skill_rank']),
      energySkillRank: Rank.listFromJsonArray(json['energy_skill_rank']),
      floors: Floor.listFromJsonArray(json['floors']),
      totalStar: json['total_star'],
      isUnlock: json['is_unlock'],
    );
  }

  Map toJson() {
    return {
      'schedule_id': scheduleId,
      'start_time': startTime,
      'end_time': endTime,
      'total_battle_times': totalBattleTimes,
      'total_win_times': totalWinTimes,
      'max_floor': maxFloor,
      'reveal_rank': revealRank,
      'defeat_rank': defeatRank,
      'damage_rank': damageRank,
      'take_damage_rank': takeDamageRank,
      'normal_skill_rank': normalSkillRank,
      'energy_skill_rank': energySkillRank,
      'floors': floors,
      'total_star': totalStar,
      'is_unlock': isUnlock,
    };
  }
}

class FullAbyssInfo {
  final CachedAPIResponse<AbyssInfo> currentPeriod;
  final CachedAPIResponse<AbyssInfo> previousPeriod;

  FullAbyssInfo({required this.currentPeriod, required this.previousPeriod});
}

class Artifact {
  final int id;
  final String name;
  final String icon;
  final int pos;
  final int rarity;
  final int level;
  final ArtifactSet set;

  String get description => '${set.name} +$level';

  Artifact({
    required this.id,
    required this.name,
    required this.icon,
    required this.pos,
    required this.rarity,
    required this.level,
    required this.set,
  });

  static Artifact fromJson(Map<String, dynamic> json) {
    return Artifact(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      pos: json['pos'],
      rarity: json['rarity'],
      level: json['level'],
      set: ArtifactSet.fromJson(json['set']),
    );
  }

  static List<Artifact> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Artifact.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'pos': pos,
      'rarity': rarity,
      'level': level,
      'set': set,
    };
  }
}

class ArtifactAffix {
  final int activationNumber;
  final String effect;

  ArtifactAffix({
    required this.activationNumber,
    required this.effect,
  });

  static ArtifactAffix fromJson(Map<String, dynamic> json) {
    return ArtifactAffix(
      activationNumber: json['activation_number'],
      effect: json['effect'],
    );
  }

  static List<ArtifactAffix> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => ArtifactAffix.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'activation_number': activationNumber,
      'effect': effect,
    };
  }
}

class ArtifactSet {
  final int id;
  final String name;
  List<ArtifactAffix> affixes;

  ArtifactSet({
    required this.id,
    required this.name,
    required this.affixes,
  });

  static ArtifactSet fromJson(Map<String, dynamic> json) {
    return ArtifactSet(
      id: json['id'],
      name: json['name'],
      affixes: ArtifactAffix.listFromJsonArray(json['affixes']),
    );
  }

  static List<ArtifactSet> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => ArtifactSet.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'affixes': affixes,
    };
  }
}

class Avatar {
  final int id;
  final String image;
  final String name;
  final String element;
  final int fetter;
  final int level;
  final int rarity;
  final int activedConstellationNum;

  Avatar({
    required this.id,
    required this.image,
    required this.name,
    required this.element,
    required this.fetter,
    required this.level,
    required this.rarity,
    required this.activedConstellationNum,
  });

  static Avatar fromJson(Map<String, dynamic> json) {
    var name = json['name'] as String;
    var image = json['image'] as String;
    if (name.isEmpty) {
      name = GenshinModule.characterName(image.split('_').last.split('.')[0]);
    }
    return Avatar(
      id: json['id'],
      image: image,
      name: name,
      element: json['element'],
      fetter: json['fetter'],
      level: json['level'],
      rarity: json['rarity'],
      activedConstellationNum: json['actived_constellation_num'],
    );
  }

  static List<Avatar> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Avatar.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'element': element,
      'fetter': fetter,
      'level': level,
      'rarity': rarity,
      'actived_constellation_num': activedConstellationNum,
    };
  }
}

class BattleAvatar {
  final int id;
  final String icon;
  final int level;
  final int rarity;

  BattleAvatar({
    required this.id,
    required this.icon,
    required this.level,
    required this.rarity,
  });

  static BattleAvatar fromJson(Map<String, dynamic> json) {
    return BattleAvatar(
      id: json['id'],
      icon: json['icon'],
      level: json['level'],
      rarity: json['id'],
    );
  }

  static List<BattleAvatar> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => BattleAvatar.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': rarity,
      'icon': rarity,
      'level': rarity,
      'rarity': rarity,
    };
  }
}

class Battle {
  final int index;
  final String timestamp;
  final List<BattleAvatar> avatars;

  Battle({
    required this.index,
    required this.timestamp,
    required this.avatars,
  });

  static Battle fromJson(Map<String, dynamic> json) {
    return Battle(
      index: json['index'],
      timestamp: json['timestamp'],
      avatars: BattleAvatar.listFromJsonArray(json['avatars']),
    );
  }

  static List<Battle> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Battle.fromJson(json[index]));
  }

  Map toJson() {
    return {
      'index': index,
      'timestamp': timestamp,
      'avatars': avatars,
    };
  }
}

class CityExploration {
  Map toJson() => {};
}

class DetailedAvatar extends Avatar {
  final Weapon weapon;
  final List<Artifact> artifacts;
  final List<Constellation> constellations;
  final List<Skin> skins;

  DetailedAvatar({
    required id,
    required image,
    required name,
    required element,
    required fetter,
    required level,
    required rarity,
    required activedConstellationNum,
    required this.weapon,
    required this.artifacts,
    required this.constellations,
    required this.skins,
  }) : super(
          id: id,
          image: image,
          name: name,
          element: element,
          fetter: fetter,
          level: level,
          rarity: rarity,
          activedConstellationNum: activedConstellationNum,
        );

  static DetailedAvatar fromJson(Map<String, dynamic> json) {
    var name = json['name'] as String;
    var image = json['image'] as String;
    if (name.isEmpty) {
      name = GenshinModule.characterName(
        image.split('_').last.split('.')[0].split("@")[0],
      );
    }
    return DetailedAvatar(
      id: json['id'],
      image: image,
      name: name,
      element: json['element'],
      fetter: json['fetter'],
      level: json['level'],
      rarity: json['rarity'],
      activedConstellationNum: json['actived_constellation_num'],
      weapon: Weapon.fromJson(json['weapon']),
      artifacts: Artifact.listFromJsonArray(json['reliquaries']),
      constellations: Constellation.listFromJsonArray(json['constellations']),
      skins: Skin.listFromJsonArray(json['costumes']),
    );
  }

  static List<DetailedAvatar> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => DetailedAvatar.fromJson(json[index]),
    );
  }

  @override
  Map toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'element': element,
      'fetter': fetter,
      'level': level,
      'rarity': rarity,
      'actived_constellation_num': activedConstellationNum,
      'weapon': weapon,
      'reliquaries': artifacts,
      'constellations': constellations,
      'costumes': skins,
    };
  }
}

class Constellation {
  final int id;
  final String name;
  final String icon;
  final String effect;
  final bool isActived;
  final int pos;

  Constellation({
    required this.id,
    required this.name,
    required this.icon,
    required this.effect,
    required this.isActived,
    required this.pos,
  });

  static Constellation fromJson(Map<String, dynamic> json) {
    return Constellation(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      effect: json['effect'],
      isActived: json['is_actived'],
      pos: json['pos'],
    );
  }

  static List<Constellation> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Constellation.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'effect': effect,
      'is_actived': isActived,
      'pos': pos,
    };
  }
}

class Floor {
  final int index;
  final String icon;
  final bool isUnlock;
  final String settleTime;
  final int star;
  final int maxStar;
  final List<Level> levels;

  Floor({
    required this.index,
    required this.icon,
    required this.isUnlock,
    required this.settleTime,
    required this.star,
    required this.maxStar,
    required this.levels,
  });

  static Floor fromJson(Map<String, dynamic> json) {
    return Floor(
      index: json['index'],
      icon: json['icon'],
      isUnlock: json['is_unlock'],
      settleTime: json['settle_time'],
      star: json['star'],
      maxStar: json['max_star'],
      levels: Level.listFromJsonArray(json['levels']),
    );
  }

  static List<Floor> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Floor.fromJson(json[index]));
  }

  Map toJson() {
    return {
      'index': index,
      'icon': icon,
      'is_unlock': isUnlock,
      'settle_time': settleTime,
      'star': star,
      'max_star': maxStar,
      'levels': levels,
    };
  }
}

class Home {
  final int level;
  final int visitNum;
  final int comfortNum;
  final int itemNum;
  final String name;
  final String icon;
  final String comfortLevelName;
  final String comfortLevelIcon;

  Home({
    required this.level,
    required this.visitNum,
    required this.comfortNum,
    required this.itemNum,
    required this.name,
    required this.icon,
    required this.comfortLevelName,
    required this.comfortLevelIcon,
  });

  static Home fromJson(Map<String, dynamic> json) {
    return Home(
      level: json['level'],
      visitNum: json['visit_num'],
      comfortNum: json['comfort_num'],
      itemNum: json['item_num'],
      name: json['name'],
      icon: json['icon'],
      comfortLevelName: json['comfort_level_name'],
      comfortLevelIcon: json['comfort_level_icon'],
    );
  }

  static List<Home> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Home.fromJson(json[index]));
  }

  Map toJson() {
    return {
      'level': level,
      'visit_num': visitNum,
      'comfort_num': comfortNum,
      'item_num': itemNum,
      'name': name,
      'icon': icon,
      'comfort_level_name': comfortLevelName,
      'comfort_level_icon': comfortLevelIcon,
    };
  }
}

class Level {
  final int index;
  final int star;
  final int maxStar;
  final List<Battle> battles;

  Level({
    required this.index,
    required this.star,
    required this.maxStar,
    required this.battles,
  });

  static Level fromJson(Map<String, dynamic> json) {
    return Level(
      index: json['index'],
      star: json['star'],
      maxStar: json['max_star'],
      battles: Battle.listFromJsonArray(json['battles']),
    );
  }

  static List<Level> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Level.fromJson(json[index]));
  }

  Map toJson() {
    return {
      'index': index,
      'star': star,
      'max_star': maxStar,
      'battles': battles,
    };
  }
}

class Offering {
  final String name;
  final int level;

  Offering({
    required this.name,
    required this.level,
  });

  static Offering fromJson(Map<String, dynamic> json) {
    return Offering(
      name: json['name'],
      level: json['level'],
    );
  }

  static List<Offering> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Offering.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'name': name,
      'level': level,
    };
  }
}

class Rank {
  final int avatarId;
  final String avatarIcon;
  final int value;
  final int rarity;

  String get name {
    if (avatarIcon.contains('Side')) {
      return avatarIcon.split("Side_")[1].split(".")[0];
    }
    return avatarIcon.split("AvatarIcon_")[1].split(".")[0];
  }

  Rank({
    required this.avatarId,
    required this.avatarIcon,
    required this.value,
    required this.rarity,
  });

  static Rank fromJson(Map<String, dynamic> json) {
    return Rank(
      avatarId: json['avatar_id'],
      avatarIcon: json['avatar_icon'],
      value: json['value'],
      rarity: json['rarity'],
    );
  }

  static List<Rank> listFromJsonArray(List<dynamic> json) {
    return List.generate(json.length, (index) => Rank.fromJson(json[index]));
  }

  Map toJson() {
    return {
      'avatar_id': avatarId,
      'avatar_icon': avatarIcon,
      'value': value,
      'rarity': rarity,
    };
  }
}

class Skin {
  final int id;
  final String name;
  final String icon;

  Skin({
    required this.id,
    required this.name,
    required this.icon,
  });

  static Skin fromJson(Map<String, dynamic> json) {
    return Skin(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }

  static List<Skin> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Skin.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}

class Stats {
  final int activeDayNumber;
  final int achievementNumber;
  final int winRate;
  final int anemoculusNumber;
  final int geoculusNumber;
  final int avatarNumber;
  final int wayPointNumber;
  final int domainNumber;
  final String spiralAbyss;
  final int preciousChestNumber;
  final int luxuriousChestNumber;
  final int exquisiteChestNumber;
  final int commonChestNumber;
  final int electroculusNumber;
  final int magicChestNumber;

  Stats({
    required this.activeDayNumber,
    required this.achievementNumber,
    required this.winRate,
    required this.anemoculusNumber,
    required this.geoculusNumber,
    required this.avatarNumber,
    required this.wayPointNumber,
    required this.domainNumber,
    required this.spiralAbyss,
    required this.preciousChestNumber,
    required this.luxuriousChestNumber,
    required this.exquisiteChestNumber,
    required this.commonChestNumber,
    required this.electroculusNumber,
    required this.magicChestNumber,
  });

  static Stats fromJson(Map<String, dynamic> json) {
    return Stats(
      activeDayNumber: json['active_day_number'],
      achievementNumber: json['achievement_number'],
      winRate: json['win_rate'],
      anemoculusNumber: json['anemoculus_number'],
      geoculusNumber: json['geoculus_number'],
      avatarNumber: json['avatar_number'],
      wayPointNumber: json['way_point_number'],
      domainNumber: json['domain_number'],
      spiralAbyss: json['spiral_abyss'],
      preciousChestNumber: json['precious_chest_number'],
      luxuriousChestNumber: json['luxurious_chest_number'],
      exquisiteChestNumber: json['exquisite_chest_number'],
      commonChestNumber: json['common_chest_number'],
      electroculusNumber: json['electroculus_number'],
      magicChestNumber: json['magic_chest_number'],
    );
  }

  Map toJson() {
    return {
      'active_day_number': activeDayNumber,
      'achievement_number': achievementNumber,
      'win_rate': winRate,
      'anemoculus_number': anemoculusNumber,
      'geoculus_number': geoculusNumber,
      'avatar_number': avatarNumber,
      'way_point_number': wayPointNumber,
      'domain_number': domainNumber,
      'spiral_abyss': spiralAbyss,
      'precious_chest_number': preciousChestNumber,
      'luxurious_chest_number': luxuriousChestNumber,
      'exquisite_chest_number': exquisiteChestNumber,
      'common_chest_number': commonChestNumber,
      'electroculus_number': electroculusNumber,
    };
  }
}

class User {}

class UserCharacters {
  final List<DetailedAvatar> avatars;

  UserCharacters({
    required this.avatars,
  });

  static UserCharacters fromJson(Map<String, dynamic> json) {
    return UserCharacters(
      avatars: DetailedAvatar.listFromJsonArray(json['avatars']),
    );
  }

  Map toJson() {
    return {
      'avatars': avatars,
    };
  }
}

class UserInfo {
  final String? role;
  final List<Avatar> avatars;
  final Stats stats;
  final List<CityExploration> cityExplorations;
  final List<WorldExploration> worldExplorations;
  final List<Home> homes;

  WorldExploration get mondstadt => worldExplorationWithID(1)!;

  WorldExploration get liyue => worldExplorationWithID(2)!;

  WorldExploration get dragonspine => worldExplorationWithID(3)!;

  WorldExploration get inazuma => worldExplorationWithID(4)!;

  WorldExploration? get enkanomiya => worldExplorationWithID(5);

  Offering get inazumaTree => inazuma.offerings.first;

  String get inazumaTreeName => "Sacred Sakura's Favor";

  Offering get dragonspineTree => dragonspine.offerings.first;

  String get dragonspineTreeName => "Frostbearing Tree";

  UserInfo({
    required this.role,
    required this.avatars,
    required this.stats,
    required this.cityExplorations,
    required this.worldExplorations,
    required this.homes,
  });

  WorldExploration? worldExplorationWithID(int id) {
    final matching = worldExplorations.where((e) => e.id == id);
    if (matching.isEmpty) return null;
    return matching.first;
  }

  static UserInfo fromJson(Map<String, dynamic> json) {
    return UserInfo(
      role: json['role'],
      avatars: Avatar.listFromJsonArray(json['avatars']),
      stats: Stats.fromJson(json['stats']),
      cityExplorations: <CityExploration>[],
      // json['city_explorations']),
      worldExplorations: WorldExploration.listFromJsonArray(
        json['world_explorations'],
      ),
      homes: Home.listFromJsonArray(json['homes']),
    );
  }

  Map toJson() {
    return {
      'role': role,
      'avatars': avatars,
      'stats': stats,
      'city_explorations': cityExplorations,
      'world_explorations': worldExplorations,
      'homes': homes,
    };
  }
}

class WorldExploration {
  final int id;
  final int level;
  final int explorationPercentage;
  final String icon;
  final String name;
  final String type;
  final List<Offering> offerings;

  double get percentage => explorationPercentage / 10;

  WorldExploration({
    required this.id,
    required this.level,
    required this.explorationPercentage,
    required this.icon,
    required this.name,
    required this.type,
    required this.offerings,
  });

  static WorldExploration fromJson(Map<String, dynamic> json) {
    return WorldExploration(
      id: json['id'],
      level: json['level'],
      explorationPercentage: json['exploration_percentage'],
      icon: json['icon'],
      name: json['name'],
      type: json['type'],
      offerings: Offering.listFromJsonArray(json['offerings']),
    );
  }

  static List<WorldExploration> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => WorldExploration.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'level': level,
      'exploration_percentage': explorationPercentage,
      'icon': icon,
      'name': name,
      'type': type,
      'offerings': offerings,
    };
  }
}

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

class Weapon {
  final int id;
  final String name;
  final String icon;
  final int type;
  final int rarity;
  final int level;
  final int promoteLevel;
  final String typeName;
  final String desc;
  final int affixLevel;

  String get line1 => 'Ascend $promoteLevel - Level $level';

  String get line2 => 'Refinement $affixLevel';

  Weapon({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.level,
    required this.promoteLevel,
    required this.typeName,
    required this.desc,
    required this.affixLevel,
  });

  static Weapon fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
      rarity: json['rarity'],
      level: json['level'],
      promoteLevel: json['promote_level'],
      typeName: json['type_name'],
      desc: json['desc'],
      affixLevel: json['affix_level'],
    );
  }

  static List<Weapon> listFromJsonArray(List<dynamic> json) {
    return List.generate(
      json.length,
      (index) => Weapon.fromJson(json[index]),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'rarity': rarity,
      'level': level,
      'promote_level': promoteLevel,
      'type_name': typeName,
      'desc': desc,
      'affix_level': affixLevel,
    };
  }
}

class WrappedUserInfo {
  final Message sentMessage;
  final double cacheTime;
  final UserInfo userInfo;
  final UserInfo? oldUserInfo;

  WrappedUserInfo({
    required this.sentMessage,
    required this.cacheTime,
    required this.userInfo,
    required this.oldUserInfo,
  });
}
