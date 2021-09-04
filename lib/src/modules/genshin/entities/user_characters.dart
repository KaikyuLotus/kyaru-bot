import 'detailed_avatar.dart';

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
}
