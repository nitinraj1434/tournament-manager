class EntryModel {
  final String entryId;
  final String tournamentId;
  final String userId;
  final String status; // "confirmed", "cancelled", "completed"
  final double paidAmount;
  final double winnings;
  final int kills;

  EntryModel({
    required this.entryId,
    required this.tournamentId,
    required this.userId,
    required this.status,
    required this.paidAmount,
    this.winnings = 0.0,
    this.kills = 0,
  });

  factory EntryModel.fromMap(Map<String, dynamic> data, String id) {
    return EntryModel(
      entryId: id,
      tournamentId: data['tournamentId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'confirmed',
      paidAmount: (data['paidAmount'] ?? 0.0).toDouble(),
      winnings: (data['winnings'] ?? 0.0).toDouble(),
      kills: data['kills'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'userId': userId,
      'status': status,
      'paidAmount': paidAmount,
      'winnings': winnings,
      'kills': kills,
    };
  }
}
