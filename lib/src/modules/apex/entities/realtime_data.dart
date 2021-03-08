class RealtimeData {
  String? lobbyState;
  bool? isOnline;
  bool? isInGame;
  bool? canJoin;
  bool? partyFull;
  String? selectedLegend;

  RealtimeData(
    this.lobbyState,
    this.selectedLegend, {
    this.partyFull,
    this.canJoin,
    this.isOnline,
    this.isInGame,
  });

  static RealtimeData fromJson(Map<String, dynamic> json) {
    return RealtimeData(
      json['lobbyState'],
      json['selectedLegend'],
      partyFull: json['partyFull'] == 1,
      canJoin: json['canJoin'] == 1,
      isOnline: json['isOnline'] == 1,
      isInGame: json['isInGame'] == 1,
    );
  }
}
