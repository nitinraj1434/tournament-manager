import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentModel {
  final String id;
  final String title;
  final String gameType;
  final DateTime date;
  final String time;
  final double entryFee;
  final int slots;
  final double prize;
  final String rules;
  final String imageUrl;
  final String bannerUrl;
  final String status; // "published", "draft", "cancelled"
  final String gameId;
  final String password;
  final List<String> participants;
  final String winnerId;
  final double winningAmount;
  final String map;

  TournamentModel({
    required this.id,
    required this.title,
    required this.gameType,
    required this.date,
    required this.time,
    required this.entryFee,
    required this.slots,
    required this.prize,
    required this.rules,
    required this.imageUrl,
    this.bannerUrl = '',
    required this.status,
    this.gameId = '',
    this.password = '',
    this.participants = const [],
    this.winnerId = '',
    this.winningAmount = 0.0,
    this.map = '',
  });

  factory TournamentModel.fromMap(Map<String, dynamic> data, String id) {
    final dynamic rawDate = data['date'];
    DateTime parsedDate = DateTime.now();
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return TournamentModel(
      id: id,
      title: data['title'] ?? '',
      gameType: data['gameType'] ?? '',
      date: parsedDate,
      time: data['time'] ?? '',
      entryFee: (data['entryFee'] ?? 0.0).toDouble(),
      slots: int.tryParse('${data['slots'] ?? 0}') ?? 0,
      prize: (data['prize'] ?? 0.0).toDouble(),
      rules: data['rules'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      status: data['status'] ?? 'draft',
      gameId: data['gameId'] ?? '',
      password: data['password'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      winnerId: data['winnerId'] ?? '',
      winningAmount: (data['winningAmount'] ?? 0.0).toDouble(),
      map: data['map'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'gameType': gameType,
      'date': Timestamp.fromDate(date),
      'time': time,
      'entryFee': entryFee,
      'slots': slots,
      'prize': prize,
      'rules': rules,
      'imageUrl': imageUrl,
      'bannerUrl': bannerUrl,
      'status': status,
      'gameId': gameId,
      'password': password,
      'participants': participants,
      'winnerId': winnerId,
      'winningAmount': winningAmount,
      'map': map,
    };
  }
}
