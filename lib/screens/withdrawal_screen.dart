import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/models/withdrawal_request_model.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/widgets/custom_button.dart';
import 'package:turnament/widgets/custom_text_field.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _amountController = TextEditingController();

  // Method selection
  String _withdrawalMethod = 'upi'; // 'upi' or 'bank'

  // Controllers
  final _upiIdController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountNameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _upiIdController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _submitRequest(double currentBalance) async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (amount > currentBalance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    String details = '';
    if (_withdrawalMethod == 'upi') {
      if (_upiIdController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter UPI ID')));
        return;
      }
      details = 'UPI: ${_upiIdController.text.trim()}';
    } else {
      if (_accountNumberController.text.trim().isEmpty ||
          _ifscController.text.trim().isEmpty ||
          _accountNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all bank details')),
        );
        return;
      }
      details =
          'Bank: ${_accountNameController.text.trim()}, '
          'Acc: ${_accountNumberController.text.trim()}, '
          'IFSC: ${_ifscController.text.trim()}';
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await _dbService.requestWithdrawal(
        _auth.currentUser!.uid,
        amount,
        details,
      );
      _amountController.clear();
      _upiIdController.clear();
      _accountNumberController.clear();
      _ifscController.clear();
      _accountNameController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request submitted')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw Money'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: StreamBuilder<UserModel?>(
        stream: _dbService.getUser(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppConstants.currencySymbol}${user.walletBalance}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Amount',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Withdrawal Method',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'UPI',
                          style: TextStyle(color: AppColors.onSurface),
                        ),
                        value: 'upi',
                        // ignore: deprecated_member_use
                        groupValue: _withdrawalMethod,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        // ignore: deprecated_member_use
                        onChanged: (val) =>
                            setState(() => _withdrawalMethod = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Bank Transfer',
                          style: TextStyle(color: AppColors.onSurface),
                        ),
                        value: 'bank',
                        // ignore: deprecated_member_use
                        groupValue: _withdrawalMethod,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        // ignore: deprecated_member_use
                        onChanged: (val) =>
                            setState(() => _withdrawalMethod = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_withdrawalMethod == 'upi')
                  CustomTextField(
                    label: 'UPI ID (e.g. user@upi)',
                    controller: _upiIdController,
                  )
                else ...[
                  CustomTextField(
                    label: 'Account Holder Name',
                    controller: _accountNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Account Number',
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'IFSC Code',
                    controller: _ifscController,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Submit Request',
                  onPressed: () => _submitRequest(user.walletBalance),
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 32),
                const Text('Withdrawal History', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                StreamBuilder<List<WithdrawalRequestModel>>(
                  stream: _dbService.getUserWithdrawalRequests(
                    _auth.currentUser!.uid,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No withdrawal requests yet',
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
                        final req = snapshot.data![index];
                        Color statusColor;
                        switch (req.status) {
                          case 'approved':
                            statusColor = Colors.green;
                            break;
                          case 'rejected':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.red;
                        }

                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              '${AppConstants.currencySymbol}${req.amount}',
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(req.timestamp),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                if (req.details.isNotEmpty)
                                  Text(
                                    req.details,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                req.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80), // Bottom padding for scrolling
              ],
            ),
          );
        },
      ),
    );
  }
}
