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
