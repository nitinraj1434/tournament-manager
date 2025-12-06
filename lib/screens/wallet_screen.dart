import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/transaction_model.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/models/wallet_request_model.dart';
import 'package:turnament/screens/deposit_screen.dart';
import 'package:turnament/screens/withdrawal_screen.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/widgets/custom_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      body: StreamBuilder<UserModel?>(
        stream: _dbService.getUser(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          final balance = user?.walletBalance ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppConstants.currencySymbol}$balance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Deposit',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DepositScreen(),
                            ),
                          );
                        },
                        color: Colors.green,
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Withdraw',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WithdrawalScreen(),
                            ),
                          );
                        },
                        color: Colors.redAccent,
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Pending Requests
                StreamBuilder<List<WalletRequestModel>>(
                  stream: _dbService.getUserWalletRequests(
                    _auth.currentUser!.uid,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final pendingRequests = snapshot.data!
                        .where((req) => req.status == 'pending')
                        .toList();

                    if (pendingRequests.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Deposits',
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingRequests.length,
                          itemBuilder: (context, index) {
                            final req = pendingRequests[index];
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.orange.withValues(alpha: 0.5),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Deposit Details'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Amount: ${AppConstants.currencySymbol}${req.amount}',
                                          ),
                                          const SizedBox(height: 8),
                                          Text('UTR: ${req.utr}'),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Status: ${req.status.toUpperCase()}',
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Date: ${DateFormat('MMM d, yyyy h:mm a').format(req.timestamp)}',
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  'Deposit Request',
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'UTR: ${req.utr}\n${DateFormat('MMM d, h:mm a').format(req.timestamp)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  '+${AppConstants.currencySymbol}${req.amount}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                const Text(
                  'Recent Transactions',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),

                // Transactions List
                StreamBuilder<List<TransactionModel>>(
                  stream: _dbService.getUserTransactions(
                    _auth.currentUser!.uid,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No transactions yet',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final txn = snapshot.data![index];
                        final isCredit = txn.type == 'credit';
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Transaction Details'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Type: ${isCredit ? 'Credit' : 'Debit'}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Amount: ${AppConstants.currencySymbol}${txn.amount}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Label: ${txn.label}'),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Status: ${txn.status.toUpperCase()}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date: ${DateFormat('MMM d, yyyy h:mm a').format(txn.timestamp)}',
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: isCredit
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isCredit ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              txn.label.isNotEmpty
                                  ? txn.label
                                  : (isCredit
                                        ? 'Wallet Topup'
                                        : 'Tournament Entry'),
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, h:mm a').format(txn.timestamp),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              '${isCredit ? '+' : '-'}${AppConstants.currencySymbol}${txn.amount}',
                              style: TextStyle(
                                color: isCredit ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
