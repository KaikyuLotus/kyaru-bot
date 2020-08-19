class RealtimeData {
  String lobbyState;
  bool isOnline;
  bool isInGame;
  bool canJoin;
  bool partyFull;
  String selectedLegend;

  RealtimeData(
    this.lobbyState,
    this.isOnline,
    this.isInGame,
    this.canJoin,
    this.partyFull,
    this.selectedLegend,
  );

  factory RealtimeData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return RealtimeData(
      json['lobbyState'],
      json['isOnline'] == 1,
      json['isInGame'] == 1,
      json['canJoin'] == 1,
      json['partyFull'] == 1,
      json['selectedLegend'],
    );
  }
}
