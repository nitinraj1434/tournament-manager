import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String txnId;
  final String userId;
  final double amount;
  final String type; // "credit", "debit"
  final String status; // "success", "failed", "pending"
  final DateTime timestamp;
  final String label;

  TransactionModel({
    required this.txnId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.label = '',
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data, String id) {
    final dynamic rawTimestamp = data['timestamp'];
    DateTime parsedTimestamp = DateTime.now();
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    }

    return TransactionModel(
      txnId: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'credit',
      status: data['status'] ?? 'pending',
      timestamp: parsedTimestamp,
      label: data['label'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'label': label,
    };
  }
}
