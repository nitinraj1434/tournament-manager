import 'package:cloud_firestore/cloud_firestore.dart';

class WalletRequestModel {
  final String requestId;
  final String userId;
  final double amount;
  final String utr;
  final String status; // "pending", "approved", "rejected"
  final DateTime timestamp;

  WalletRequestModel({
    required this.requestId,
    required this.userId,
    required this.amount,
    required this.utr,
    required this.status,
    required this.timestamp,
  });

  factory WalletRequestModel.fromMap(Map<String, dynamic> data, String id) {
    final dynamic rawTimestamp = data['timestamp'];
    DateTime parsedTimestamp = DateTime.now();
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    }

    return WalletRequestModel(
      requestId: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      utr: data['utr'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'utr': utr,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
