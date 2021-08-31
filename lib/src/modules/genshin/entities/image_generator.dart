import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:image/image.dart' as imglib;
import 'package:kyaru_bot/src/modules/genshin/entities/userinfo.dart';

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
  var stringWidth = 0;
  var stringHeight = 0;

  if (x == null || y == null) {
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
  }

  int xPos, yPos;
  if (x == null) {
    xPos = (width / 2).round() - (stringWidth / 2).round();
  } else {
    xPos = x;
  }
  if (y == null) {
    yPos = (height / 2).round() - (stringHeight / 2).round();
  } else {
    yPos = y;
  }

  return imglib.drawString(
    image,
    font,
    xPos + offsetX,
    yPos + offsetY,
    string,
    color: color,
  );
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

  await Directory('resources/caches').create();
  await Directory('resources/caches/avatar').create();
  await Directory('resources/caches/element').create();

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
