import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalRequestModel {
  final String requestId;
  final String userId;
  final double amount;
  final String details;
  final String status; // "pending", "approved", "rejected"
  final DateTime timestamp;

  WithdrawalRequestModel({
    required this.requestId,
    required this.userId,
    required this.amount,
    required this.details,
    required this.status,
    required this.timestamp,
  });

  factory WithdrawalRequestModel.fromMap(Map<String, dynamic> data, String id) {
    final dynamic rawTimestamp = data['timestamp'];
    DateTime parsedTimestamp = DateTime.now();
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    }

    return WithdrawalRequestModel(
      requestId: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      details: data['details'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'details': details,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
