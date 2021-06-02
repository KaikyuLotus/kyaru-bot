import 'package:xml/xml.dart';

class Group {
  final String id64;
  final String name;
  final String summary;
  final String avatarIcon;
  final String avatarMedium;
  final String avatarFull;
  final String memberCount;
  final String membersInChat;
  final String membersInGame;
  final String membersOnline;

  Group(
    this.id64,
    this.name,
    this.summary,
    this.avatarIcon,
    this.avatarMedium,
    this.avatarFull,
    this.memberCount,
    this.membersInChat,
    this.membersInGame,
    this.membersOnline,
  );

  static Group fromXml(String xml) {
    var xmlData = XmlDocument.parse(xml).getElement('memberList')!;
    var details = xmlData.getElement('groupDetails')!;
    return Group(
      xmlData.getElement('groupID64')!.text,
      details.getElement('groupName')!.text,
      details.getElement('summary')!.text,
      details.getElement('avatarIcon')!.text,
      details.getElement('avatarMedium')!.text,
      details.getElement('avatarFull')!.text,
      details.getElement('memberCount')!.text,
      details.getElement('membersInChat')!.text,
      details.getElement('membersInGame')!.text,
      details.getElement('membersOnline')!.text,
    );
  }
}
