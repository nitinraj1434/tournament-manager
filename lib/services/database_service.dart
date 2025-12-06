import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turnament/models/config_model.dart';
import 'package:turnament/models/entry_model.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/models/transaction_model.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/models/wallet_request_model.dart';
import 'package:turnament/models/withdrawal_request_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _configDocId = 'global_config';
  static const String _sampleUserId = 'demoUser';
  static const String _sampleTournamentOne = 'sampleTournamentOne';
  static const String _sampleTournamentTwo = 'sampleTournamentTwo';

  // Users
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String photoUrl,
    required String phoneNumber,
    required String bio,
    required String address,
    required String gameUid,
    required String gameName,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'address': address,
      'gameUid': gameUid,
      'gameName': gameName,
    }, SetOptions(merge: true));
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Future<void> updateUserToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  Stream<UserModel?> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Tournaments
  Stream<List<TournamentModel>> getTournaments() {
    return _db.collection('tournaments').orderBy('date').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => TournamentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<TournamentModel?> getTournamentById(String tournamentId) {
    return _db.collection('tournaments').doc(tournamentId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return null;
      return TournamentModel.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
      );
    });
  }

  Future<void> createTournament(TournamentModel tournament) async {
    await _db.collection('tournaments').add(tournament.toMap());
  }

  Future<void> updateTournament(TournamentModel tournament) async {
    await _db
        .collection('tournaments')
        .doc(tournament.id)
        .update(tournament.toMap());
  }

  Future<void> finishTournament(
    String tournamentId,
    String winnerId,
    double winningAmount,
  ) async {
    await _db.runTransaction((transaction) async {
      DocumentReference tournamentRef = _db
          .collection('tournaments')
          .doc(tournamentId);
      DocumentReference winnerRef = _db.collection('users').doc(winnerId);
      DocumentReference txnRef = _db.collection('transactions').doc();

      DocumentSnapshot tournamentSnapshot = await transaction.get(
        tournamentRef,
      );
      DocumentSnapshot winnerSnapshot = await transaction.get(winnerRef);

      if (!tournamentSnapshot.exists) {
        throw Exception("Tournament not found!");
      }
      if (!winnerSnapshot.exists) {
        throw Exception("Winner not found!");
      }

      // Update Tournament
      transaction.update(tournamentRef, {
        'status': 'completed',
        'winnerId': winnerId,
        'winningAmount': winningAmount,
      });

      // Update Winner's Wallet
      double currentBalance = (winnerSnapshot.get('walletBalance') ?? 0.0)
          .toDouble();
      transaction.update(winnerRef, {
        'walletBalance': currentBalance + winningAmount,
      });

      // Create Transaction Record
      transaction.set(txnRef, {
        'userId': winnerId,
        'amount': winningAmount,
        'type': 'credit',
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        'label': 'Tournament Winnings',
        'tournamentId': tournamentId,
      });
    });
  }

  Future<void> distributePrize(
    String tournamentId,
    String userId,
    double amount,
    int kills,
  ) async {
    await _db.runTransaction((transaction) async {
      DocumentReference userRef = _db.collection('users').doc(userId);
      DocumentReference entryRef = _db
          .collection('entries')
          .doc('${tournamentId}_$userId');
      DocumentReference txnRef = _db.collection('transactions').doc();

      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      DocumentSnapshot entrySnapshot = await transaction.get(entryRef);

      if (!userSnapshot.exists) {
        throw Exception("User not found!");
      }
      if (!entrySnapshot.exists) {
        throw Exception("Entry not found!");
      }

      // Update User Wallet
      double currentBalance = (userSnapshot.get('walletBalance') ?? 0.0)
          .toDouble();
      double currentEarnings = (userSnapshot.get('totalEarnings') ?? 0.0)
          .toDouble();
      int currentWon = (userSnapshot.get('matchesWon') ?? 0) as int;

      transaction.update(userRef, {
        'walletBalance': currentBalance + amount,
        'totalEarnings': currentEarnings + amount,
        'matchesWon': amount > 0 ? currentWon + 1 : currentWon,
      });

      // Update Entry
      transaction.update(entryRef, {
        'status': 'completed',
        'winnings': amount,
        'kills': kills,
      });

      // Create Transaction Record if amount > 0
      if (amount > 0) {
        transaction.set(txnRef, {
          'userId': userId,
          'amount': amount,
          'type': 'credit',
          'status': 'success',
          'timestamp': FieldValue.serverTimestamp(),
          'label': 'Tournament Prize (Kills: $kills)',
          'tournamentId': tournamentId,
        });
      }
    });
  }

  Stream<List<EntryModel>> getTournamentParticipants(String tournamentId) {
    return _db
        .collection('entries')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EntryModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> joinTournament(
    String tournamentId,
    String userId,
    double fee,
  ) async {
    await _db.runTransaction((transaction) async {
      DocumentReference userRef = _db.collection('users').doc(userId);
      DocumentReference tournamentRef = _db
          .collection('tournaments')
          .doc(tournamentId);
      DocumentReference entryRef = _db
          .collection('entries')
          .doc('${tournamentId}_$userId');

      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      DocumentSnapshot tournamentSnapshot = await transaction.get(
        tournamentRef,
      );
      DocumentSnapshot entrySnapshot = await transaction.get(entryRef);

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }
      if (!tournamentSnapshot.exists) {
        throw Exception("Tournament not found!");
      }
      if (entrySnapshot.exists) {
        throw Exception("You already joined this tournament.");
      }

      UserModel user = UserModel.fromMap(
        userSnapshot.data()! as Map<String, dynamic>,
        userId,
      );
      TournamentModel tournament = TournamentModel.fromMap(
        tournamentSnapshot.data()! as Map<String, dynamic>,
        tournamentSnapshot.id,
      );

      if (user.gameUid.isEmpty || user.gameName.isEmpty) {
        throw Exception(
          "Please update your Game ID and Name in Profile to join.",
        );
      }

      if (tournament.status != 'published') {
        throw Exception("This tournament is not open for joining.");
      }

      if (tournament.date.isBefore(DateTime.now())) {
        throw Exception("This tournament is no longer available.");
      }

      if (tournament.slots <= 0) {
        throw Exception("Tournament is full!");
      }

      if (user.walletBalance < fee) {
        throw Exception("Insufficient balance!");
      }

      transaction.update(userRef, {'walletBalance': user.walletBalance - fee});

      transaction.set(entryRef, {
        'tournamentId': tournamentId,
        'userId': userId,
        'status': 'confirmed',
        'paidAmount': fee,
        'timestamp': FieldValue.serverTimestamp(),
      });

      DocumentReference txnRef = _db.collection('transactions').doc();
      transaction.set(txnRef, {
        'userId': userId,
        'amount': fee,
        'type': 'debit',
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        'label': 'Tournament Entry',
      });

      transaction.update(tournamentRef, {
        'participants': FieldValue.arrayUnion([userId]),
        'slots': tournament.slots - 1,
      });
    });
  }

  Stream<List<EntryModel>> getUserEntries(String userId) {
    return _db
        .collection('entries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EntryModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Wallet
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs;
        });
  }

  Future<void> requestWalletTopUp(
    String userId,
    double amount,
    String utr,
  ) async {
    if (amount <= 0) {
      throw Exception("Amount must be greater than zero.");
    }

    await _db.collection('wallet_requests').add({
      'userId': userId,
      'amount': amount,
      'utr': utr,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestWithdrawal(
    String userId,
    double amount,
    String details,
  ) async {
    if (amount <= 0) {
      throw Exception("Amount must be greater than zero.");
    }

    await _db.runTransaction((transaction) async {
      DocumentReference userRef = _db.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      double currentBalance = (userSnapshot.get('walletBalance') ?? 0.0)
          .toDouble();

      if (currentBalance < amount) {
        throw Exception("Insufficient balance!");
      }

      // Deduct balance
      transaction.update(userRef, {'walletBalance': currentBalance - amount});

      // Create withdrawal request
      DocumentReference requestRef = _db
          .collection('withdrawal_requests')
          .doc();
      transaction.set(requestRef, {
        'userId': userId,
        'amount': amount,
        'details': details,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      DocumentReference txnRef = _db.collection('transactions').doc();
      transaction.set(txnRef, {
        'userId': userId,
        'amount': amount,
        'type': 'debit',
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        'label': 'Withdrawal Request',
      });
    });
  }

  Stream<List<WithdrawalRequestModel>> getUserWithdrawalRequests(
    String userId,
  ) {
    return _db
        .collection('withdrawal_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => WithdrawalRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs;
        });
  }

  Stream<List<WalletRequestModel>> getUserWalletRequests(String userId) {
    return _db
        .collection('wallet_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => WalletRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs;
        });
  }

  Stream<List<WalletRequestModel>> getAllPendingWalletRequests() {
    return _db
        .collection('wallet_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => WalletRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in memory to avoid composite index requirement
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs;
        });
  }

  Stream<List<WithdrawalRequestModel>> getAllPendingWithdrawalRequests() {
    return _db
        .collection('withdrawal_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => WithdrawalRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs;
        });
  }

  Future<void> approveWithdrawalRequest(String requestId) async {
    await _db.collection('withdrawal_requests').doc(requestId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectWithdrawalRequest(
    String requestId,
    String userId,
    double amount,
  ) async {
    await _db.runTransaction((transaction) async {
      DocumentReference requestRef = _db
          .collection('withdrawal_requests')
          .doc(requestId);
      DocumentReference userRef = _db.collection('users').doc(userId);
      DocumentReference txnRef = _db.collection('transactions').doc();

      DocumentSnapshot requestSnapshot = await transaction.get(requestRef);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!requestSnapshot.exists) {
        throw Exception("Request does not exist!");
      }

      if (requestSnapshot.get('status') != 'pending') {
        throw Exception("Request is already processed!");
      }

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      double currentBalance = (userSnapshot.get('walletBalance') ?? 0.0)
          .toDouble();

      // Update request status
      transaction.update(requestRef, {'status': 'rejected'});

      // Refund user balance
      transaction.update(userRef, {'walletBalance': currentBalance + amount});

      // Create transaction record for refund
      transaction.set(txnRef, {
        'userId': userId,
        'amount': amount,
        'type': 'credit',
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        'label': 'Withdrawal Refund',
      });
    });
  }

  Future<void> approveWalletRequest(
    String requestId,
    String userId,
    double amount,
  ) async {
    await _db.runTransaction((transaction) async {
      DocumentReference requestRef = _db
          .collection('wallet_requests')
          .doc(requestId);
      DocumentReference userRef = _db.collection('users').doc(userId);
      DocumentReference txnRef = _db.collection('transactions').doc();

      DocumentSnapshot requestSnapshot = await transaction.get(requestRef);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!requestSnapshot.exists) {
        throw Exception("Request does not exist!");
      }

      if (requestSnapshot.get('status') != 'pending') {
        throw Exception("Request is already processed!");
      }

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      double currentBalance = (userSnapshot.get('walletBalance') ?? 0.0)
          .toDouble();

      // Update request status
      transaction.update(requestRef, {'status': 'approved'});

      // Update user balance
      transaction.update(userRef, {'walletBalance': currentBalance + amount});

      // Create transaction record
      transaction.set(txnRef, {
        'userId': userId,
        'amount': amount,
        'type': 'credit',
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        'label': 'Wallet Topup',
      });
    });
  }

  Future<void> rejectWalletRequest(String requestId) async {
    await _db.collection('wallet_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  // Config
  Stream<ConfigModel> getConfig() {
    return _db.collection('config').doc(_configDocId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return ConfigModel.fromMap(snapshot.data()!);
      } else {
        return ConfigModel(upiId: '', qrImageUrl: '');
      }
    });
  }

  // Auto-generation
  Future<void> initializeDefaultData() async {
    final batch = _db.batch();
    var hasWrites = false;

    final configRef = _db.collection('config').doc(_configDocId);
    if (!(await configRef.get()).exists) {
      batch.set(configRef, {
        'upiId': 'turnament@upi',
        'qrImageUrl':
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300',
      });
      hasWrites = true;
    }

    final sampleUserRef = _db.collection('users').doc(_sampleUserId);
    if (!(await sampleUserRef.get()).exists) {
      batch.set(sampleUserRef, {
        'name': 'Demo Player',
        'email': 'demo@turnament.app',
        'photoUrl': '',
        'walletBalance': 250.0,
        'role': 'user',
      });
      hasWrites = true;
    }

    final now = DateTime.now();
    final tournamentOneRef = _db
        .collection('tournaments')
        .doc(_sampleTournamentOne);
    if (!(await tournamentOneRef.get()).exists) {
      batch.set(tournamentOneRef, {
        'title': 'PUBG Mobile Daily Scrims',
        'gameType': 'Battle Royale',
        'date': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'time': '8:00 PM',
        'entryFee': 50.0,
        'slots': 100,
        'prize': 500.0,
        'rules': 'No hacking. Be on time.',
        'imageUrl':
            'https://images.unsplash.com/photo-1527443224154-c4a3942d3efe?w=500',
        'status': 'published',
      });
      hasWrites = true;
    }

    final tournamentTwoRef = _db
        .collection('tournaments')
        .doc(_sampleTournamentTwo);
    if (!(await tournamentTwoRef.get()).exists) {
      batch.set(tournamentTwoRef, {
        'title': 'Free Fire Clash Squad',
        'gameType': 'Clash Squad',
        'date': Timestamp.fromDate(now.add(const Duration(days: 2))),
        'time': '9:00 PM',
        'entryFee': 30.0,
        'slots': 50,
        'prize': 300.0,
        'rules': 'Standard rules apply.',
        'imageUrl':
            'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=500',
        'status': 'published',
      });
      hasWrites = true;
    }

    final entryRef = _db
        .collection('entries')
        .doc('${_sampleTournamentOne}_$_sampleUserId');
    if (!(await entryRef.get()).exists) {
      batch.set(entryRef, {
        'tournamentId': _sampleTournamentOne,
        'userId': _sampleUserId,
        'status': 'confirmed',
        'paidAmount': 50.0,
        'timestamp': Timestamp.fromDate(now),
      });
      hasWrites = true;
    }

    final txnRef = _db.collection('transactions').doc('sampleTxn');
    if (!(await txnRef.get()).exists) {
      batch.set(txnRef, {
        'userId': _sampleUserId,
        'amount': 100.0,
        'type': 'credit',
        'status': 'success',
        'timestamp': Timestamp.fromDate(now),
        'label': 'Manual Credit',
      });
      hasWrites = true;
    }

    final walletReqRef = _db
        .collection('wallet_requests')
        .doc('sampleWalletRequest');
    if (!(await walletReqRef.get()).exists) {
      batch.set(walletReqRef, {
        'userId': _sampleUserId,
        'amount': 150.0,
        'utr': 'UTR123456',
        'status': 'approved',
        'timestamp': Timestamp.fromDate(now),
      });
      hasWrites = true;
    }

    if (hasWrites) {
      await batch.commit();
    }
  }
}
