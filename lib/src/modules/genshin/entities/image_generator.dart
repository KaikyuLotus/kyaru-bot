import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:image/image.dart' as imglib;
import 'package:kyaru_bot/src/modules/genshin/entities/genshin_client.dart';
import 'package:kyaru_bot/src/modules/genshin/entities/userinfo.dart';

import 'detailed_avatar.dart';

var iconSize = 120;
var iconDist = 10;
var maxIcons = 6;
var globalPaddingLeft = 30;
var globalPaddingTop = 30;

var elementColors = <String, int>{
  'Pyro': imglib.Color.fromRgb(254, 169, 111),
  'Hydro': imglib.Color.fromRgb(55, 200, 254),
  'Anemo': imglib.Color.fromRgb(164, 243, 203),
  'Electro': imglib.Color.fromRgb(224, 186, 255),
  'Dendro': imglib.Color.fromRgb(179, 236, 43),
  'Cryo': imglib.Color.fromRgb(201, 255, 252),
  'Geo': imglib.Color.fromRgb(245, 215, 98),
};

class Size {
  final int width;
  final int height;

  static const zero = Size(width: 0, height: 0);

  const Size({required this.width, required this.height});
}

var _random = math.Random();

// TODO remove
int next(int min, int max) => min + _random.nextInt(max - min);

Size getStringSize(imglib.BitmapFont font, String string) {
  var stringWidth = 0;
  var stringHeight = 0;

  final chars = string.codeUnits;
  for (var c in chars) {
    if (!font.characters.containsKey(c)) {
      continue;
    }
    final ch = font.characters[c]!;
    stringWidth += ch.xadvance;
    if (ch.height + ch.yoffset > stringHeight) {
      stringHeight = ch.height + ch.yoffset;
    }
  }

  return Size(width: stringWidth, height: stringHeight);
}

imglib.Image drawStringCentered(
  imglib.Image image,
  imglib.BitmapFont font,
  String string, {
  int? x,
  int? y,
  int offsetX = 0,
  int offsetY = 0,
  required int width,
  required int height,
  int color = 0xffffffff,
}) {
  Size stringSize = Size.zero;

  if (x == null || y == null) {
    stringSize = getStringSize(font, string);
  }

  var xPos = x ?? (width / 2).round() - (stringSize.width / 2).round();
  var yPos = y ?? (height / 2).round() - (stringSize.height / 2).round();

  return imglib.drawString(
    image,
    font,
    xPos + offsetX,
    yPos + offsetY,
    string,
    color: color,
  );
}

Future<imglib.Image?> getCachedImage(String url, String folder) async {
  var client = Client();
  try {
    await Directory(folder).create(recursive: true);
    var imageFileName = url.split('/').last;
    var cacheFile = File('$folder/$imageFileName');
    if (!await cacheFile.exists()) {
      var imgResp = await client.get(Uri.parse(url));
      await cacheFile.writeAsBytes(imgResp.bodyBytes);
      return imglib.decodePng(imgResp.bodyBytes);
    }
    return imglib.decodePng(await cacheFile.readAsBytes());
  } finally {
    client.close();
  }
}

Future<void> renderCharImage(
  imglib.Image canvas,
  DetailedAvatar character,
) async {
  var charImage = await getCachedImage(
    character.image,
    'resources/caches/chars',
  );

  imglib.drawImage(
    canvas,
    charImage!,
    dstX: canvas.width - charImage.width,
    dstY: 0,
    dstW: charImage.width,
    dstH: charImage.height,
  );
}

Future<int> renderItems(
  imglib.Image canvas,
  DetailedAvatar character,
) async {
  await Directory('resources/caches/weapons').create(recursive: true);
  var weaponImage = await getCachedImage(
    character.weapon.icon,
    'resources/caches/weapons',
  );

  var itemBgColor = imglib.Color.fromRgb(29, 29, 29);
  var iconBgColor = imglib.Color.fromRgb(19, 19, 19);

  var iconExtraPaddingTop = 10;

  var iconTitlePaddingLeft = 10;
  var iconTitlePaddingRight = 10;
  var stringPadding = 10;

  var nameSizes = <int>[];
  for (var artifact in character.artifacts) {
    nameSizes.add(getStringSize(imglib.arial_24, artifact.name).width);
  }
  nameSizes.add(getStringSize(imglib.arial_24, character.weapon.name).width);
  nameSizes.add(getStringSize(imglib.arial_24, character.weapon.line1).width);
  nameSizes.add(getStringSize(imglib.arial_24, character.weapon.line2).width);
  for (var artifact in character.artifacts) {
    nameSizes.add(getStringSize(imglib.arial_24, artifact.description).width);
  }

  var maxNameSize = nameSizes.reduce(math.max) + iconTitlePaddingLeft;

  drawItem(
    int index,
    imglib.Image image,
    int itemBorderColor,
    String name, {
    String? line1,
    String? line2,
  }) {
    var nameHeight = getStringSize(imglib.arial_24, name).height;

    imglib.fillRect(
      canvas,
      globalPaddingLeft,
      iconSize * index + iconDist * index + globalPaddingTop,
      iconSize + globalPaddingLeft + iconTitlePaddingRight + maxNameSize,
      iconSize * (index + 1) + iconDist * index + globalPaddingTop,
      itemBgColor,
    );

    imglib.fillRect(
      canvas,
      globalPaddingLeft,
      (iconSize + iconDist) * index + globalPaddingTop,
      globalPaddingLeft + iconSize,
      iconSize * (index + 1) + (iconDist) * index + globalPaddingTop,
      iconBgColor,
    );

    imglib.drawImage(
      canvas,
      image,
      dstX: globalPaddingLeft,
      dstY: (iconSize + iconDist) * index + globalPaddingTop,
      dstW: iconSize,
      dstH: iconSize,
    );

    imglib.drawString(
      canvas,
      imglib.arial_24,
      iconSize + globalPaddingLeft + iconTitlePaddingLeft,
      iconSize * index + globalPaddingTop + iconDist * index + stringPadding,
      name,
    );

    if (line1 != null) {
      imglib.drawString(
        canvas,
        imglib.arial_24,
        iconSize + globalPaddingLeft + iconTitlePaddingLeft,
        iconSize * index +
            globalPaddingTop +
            iconDist * index +
            nameHeight +
            iconExtraPaddingTop +
            stringPadding,
        line1,
        color: 0xAAFFFFFF,
      );
    }

    if (line2 != null) {
      imglib.drawString(
        canvas,
        imglib.arial_24,
        iconSize + globalPaddingLeft + iconTitlePaddingLeft,
        iconSize * index +
            globalPaddingTop +
            iconDist * index +
            nameHeight +
            iconExtraPaddingTop +
            stringPadding +
            28,
        line2,
        color: 0xAAFFFFFF,
      );
    }

    imglib.drawRect(
      canvas,
      globalPaddingLeft,
      (iconSize + iconDist) * index + globalPaddingTop,
      globalPaddingLeft + iconSize,
      iconSize * (index + 1) + (iconDist) * index + globalPaddingTop,
      itemBorderColor,
    );
  }

  var colorMap = <int, int>{
    1: imglib.Color.fromRgb(255, 255, 255),
    2: imglib.Color.fromRgb(127, 255, 0),
    3: imglib.Color.fromRgb(173, 216, 230),
    4: imglib.Color.fromRgb(138, 43, 226),
    5: imglib.Color.fromRgb(255, 215, 0),
  };

  drawItem(
    0,
    weaponImage!,
    colorMap[character.weapon.rarity] ?? 0x000000,
    character.weapon.name,
    line1: character.weapon.line1,
    line2: character.weapon.line2,
  );
  for (int index = 0; index < character.artifacts.length; index++) {
    var artifact = character.artifacts[index];
    var image = await getCachedImage(
      artifact.icon,
      'resources/caches/artifacts',
    );
    print(artifact.name);
    print(artifact.rarity);
    drawItem(
      index + 1,
      image!,
      colorMap[artifact.rarity] ?? 0x000000,
      artifact.name,
      line1: artifact.description,
    );
  }

  return maxNameSize + iconSize + iconTitlePaddingRight;
}

Future<void> renderConsts(
  imglib.Image canvas,
  DetailedAvatar character,
  int cardWidth,
) async {
  var constDistV = 35;
  var constBarHeight = 10;
  var iconsMargin = 10;
  var startX = globalPaddingLeft + iconsMargin;
  var startY = (iconSize + iconDist) * maxIcons + globalPaddingTop;
  var index = 0;
  var row = 0;
  for (var constellation in character.constellations) {
    var img = await getCachedImage(
      constellation.icon,
      'resources/caches/constellations',
    );

    // Spacing considers 3 consts per row
    var spacingH = (cardWidth - img!.width * 3) ~/ 2;
    spacingH -= iconsMargin;

    if (spacingH < 0) {
      spacingH = 2;
    }

    var x = startX + ((img.width + spacingH) * index);
    var y = startY + ((img.height + constDistV + constBarHeight) * row);

    var shadowColor = 0x22FFFFFF;
    if (constellation.isActived) {
      shadowColor = elementColors[character.element]!;
      imglib.scaleRgba(
        img,
        imglib.getRed(shadowColor),
        imglib.getGreen(shadowColor),
        imglib.getBlue(shadowColor),
        imglib.getAlpha(shadowColor),
      );
      imglib.copyInto(img, img);
    }
    imglib.fillRect(
      canvas,
      x,
      y + img.height,
      x + img.width,
      y + img.height + constBarHeight,
      shadowColor,
    );

    imglib.drawImage(
      canvas,
      img,
      dstX: x,
      dstY: y,
    );

    index++;
    if (index == 3) {
      index = 0;
      row += 1;
    }
  }
  // imglib.drawString(canvas, imglib.arial_24, startX, startY, 'Qui?');
}

Future<List<int>?> generateCharacterImage(DetailedAvatar character) async {
  var bgColor = imglib.Color.fromRgb(39, 39, 39);
  var canvasWidth = 1024;
  var canvasHeight = 1108;

  var canvas = imglib.Image(
    canvasWidth,
    canvasHeight,
    channels: imglib.Channels.rgb,
  );

  canvas.fill(bgColor);

  await renderCharImage(canvas, character);

  var cardWidth = await renderItems(canvas, character);

  await renderConsts(canvas, character, cardWidth);

  return Uint8List.fromList(imglib.encodePng(canvas));
}

Future<List<int>?> generateAvatarsImage(UserInfo data) async {
  // var radiusMultiplier = 2.0;

  var footerHeight = 40;

  var avatarWidth = 256;
  var avatarHeight = 256;

  var paddingH = 12;
  var paddingW = 12;
  var elementH = avatarWidth ~/ 5;
  var friendshipH = avatarWidth ~/ 7;
  var constellationH = 12;
  var constellationPadding = 5;
  var maxCols = 5;

  var row = 0;
  var col = 0;

  var footerColor = imglib.Color.fromRgba(39, 39, 39, 190);
  var bgColor = imglib.Color.fromRgb(39, 39, 39);

  var client = Client();

  var maxRows = (data.avatars.length / maxCols).ceil();

  var bg4Star = imglib.decodePng(
    await File('resources/images/bg4star.png').readAsBytes(),
  );
  var bg5Star = imglib.decodePng(
    await File('resources/images/bg5star.png').readAsBytes(),
  );
  var bgFriendship = imglib.decodePng(
    await File('resources/images/Item_Companionship_EXP.png').readAsBytes(),
  );
  var bgExp = imglib.decodePng(
    await File('resources/images/Item_Character_EXP.png').readAsBytes(),
  );
  var ascensionIcn = imglib.decodePng(
    await File('resources/images/ascension.png').readAsBytes(),
  );

  if (bg4Star == null ||
      bg5Star == null ||
      bgFriendship == null ||
      bgExp == null ||
      ascensionIcn == null) {
    print('Could not load an image from images folder');
    return null;
  }

  var canvas = imglib.Image(
    (avatarWidth + paddingW) * maxCols,
    (avatarHeight + paddingH) * maxRows,
    channels: imglib.Channels.rgb,
  );

  canvas.fill(bgColor);

  data.avatars.sort((a1, a2) {
    var firstComp = a2.level.compareTo(a1.level);
    if (firstComp == 0) {
      return a2.rarity.compareTo(a1.rarity);
    }
    return firstComp;
  });

  await Directory('resources/caches/avatar').create(recursive: true);
  await Directory('resources/caches/element').create(recursive: true);

  for (var avatar in data.avatars) {
    if (row == maxRows) {
      throw Exception('Insufficient rows');
    }

    var name = avatar.name;
    var constellation = avatar.activedConstellationNum;
    var level = avatar.level;
    var friendship = avatar.fetter;
    var element = avatar.element;
    var imageUrl = avatar.image;
    var imageFileName = imageUrl.split('/').last;
    var cacheFile = File('resources/caches/avatar/$imageFileName');
    var cacheElement = File('resources/caches/element/$element.png');
    if (!await cacheFile.exists()) {
      var imgResp = await client.get(Uri.parse(imageUrl));
      await cacheFile.writeAsBytes(imgResp.bodyBytes);
    }
    if (!await cacheElement.exists()) {
      var imgResp = await client.get(
        Uri.parse(
          'https://rerollcdn.com/GENSHIN/Elements/Element_$element.png',
        ),
      );
      await cacheElement.writeAsBytes(imgResp.bodyBytes);
    }

    var imageBytes = await cacheFile.readAsBytes();
    var avatarImage = imglib.decodePng(imageBytes);
    if (avatarImage == null) {
      print('AvatarImage is null');
      return null;
    }

    var elemImageBytes = await cacheElement.readAsBytes();
    var elemImage = imglib.decodePng(elemImageBytes);
    if (elemImage == null) {
      print('ElemImage is null');
      return null;
    }

    var x = avatarWidth * col + paddingW * col;
    var y = avatarHeight * row + paddingH * row;

    imglib.drawImage(
      canvas,
      avatar.rarity == 5 ? bg5Star : bg4Star,
      dstX: x,
      dstY: y,
      dstW: avatarWidth,
      dstH: avatarHeight,
    );

    imglib.drawImage(
      canvas,
      avatarImage,
      dstX: x,
      dstY: y,
      dstW: avatarWidth,
      dstH: avatarHeight,
    );

    imglib.fillRect(
      canvas,
      x,
      y + avatarHeight - footerHeight,
      x + avatarWidth,
      y + avatarHeight,
      footerColor,
    );

    imglib.drawImage(
      canvas,
      elemImage,
      dstX: x + avatarWidth - elementH,
      dstY: y,
      dstH: elementH,
      dstW: elementH,
    );
    if (friendship > 0) {
      imglib.fillRect(
        canvas,
        x + avatarWidth - friendshipH * 2,
        y + avatarHeight - footerHeight - friendshipH - 1,
        x + avatarWidth,
        y + avatarHeight - footerHeight - 1,
        footerColor,
      );

      imglib.drawImage(
        canvas,
        bgFriendship,
        dstX: x + avatarWidth - friendshipH,
        dstY: y + avatarHeight - footerHeight - friendshipH,
        dstH: friendshipH,
        dstW: friendshipH,
      );

      drawStringCentered(
        canvas,
        imglib.arial_24,
        '$friendship',
        width: friendshipH,
        height: friendshipH,
        offsetX: x + avatarWidth - friendshipH * 2,
        offsetY: y + avatarHeight - footerHeight - friendshipH,
      );
    }

    imglib.fillRect(
      canvas,
      x + friendshipH * 2,
      y + avatarHeight - footerHeight - friendshipH - 1,
      x,
      y + avatarHeight - footerHeight - 1,
      footerColor,
    );

    imglib.drawImage(
      canvas,
      bgExp,
      dstX: x,
      dstY: y + avatarHeight - footerHeight - friendshipH,
      dstH: friendshipH,
      dstW: friendshipH,
    );

    drawStringCentered(
      canvas,
      imglib.arial_24,
      '$level',
      width: friendshipH,
      height: friendshipH,
      offsetX: x + friendshipH,
      offsetY: y + avatarHeight - footerHeight - friendshipH,
    );

    drawStringCentered(
      canvas,
      imglib.arial_24,
      name,
      width: avatarWidth,
      height: footerHeight,
      offsetX: x,
      offsetY: y + avatarHeight - footerHeight,
    );

    for (var i = 0; i < 6; i++) {
      imglib.fillCircle(
        canvas,
        x + constellationH ~/ 2 + constellationPadding,
        y +
            constellationH ~/ 2 +
            (constellationPadding * (i + 1)) +
            (constellationH * i),
        constellationH ~/ 2,
        i >= constellation ? 0x33000000 : 0xDDFFFFFF,
      );
    }

    col++;
    if (col == maxCols) {
      col = 0;
      row++;
    }
  }

  return Uint8List.fromList(imglib.encodePng(canvas));
}

// Used for local testing
Future<void> main() async {
  var client = GenshinClient('localhost:8457');
  var user = await client.getUser(700103901);

  var userInfo = UserInfo.fromJson(user['data']['data']['data']);
  var ids = userInfo.avatars.map((a) => a.id).toList();
  var userCharacters = await client.getCharacters(700103901, ids);
  print(userCharacters.avatars.map((a) => a.name).join(","));
  var avatar = userCharacters.avatars[9];
  print(avatar.element);
  var bytes = await generateCharacterImage(avatar);
  if (bytes == null) {
    print('Generation failed');
    return;
  }
  await File('output.jpg').writeAsBytes(bytes);

  client.close();
}
