import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/config_model.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/widgets/custom_button.dart';
import 'package:turnament/widgets/custom_text_field.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _amountController = TextEditingController();
  final _utrController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    final amount = double.tryParse(_amountController.text.trim());
    final utr = _utrController.text.trim();

    if (amount == null || amount <= 0 || utr.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await _dbService.requestWalletTopUp(_auth.currentUser!.uid, amount, utr);
      _amountController.clear();
      _utrController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
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
        title: const Text('Deposit Money'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<ConfigModel>(
              stream: _dbService.getConfig(),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Scan QR to Pay',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/payment_qr.jpg',
                              height: 250,
                              width: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250,
                                  width: 250,
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan the QR code above to pay, then enter the amount and Transaction ID below.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Amount',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 24),
            const Divider(color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'After payment, enter UTR below to confirm',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'UTR / Transaction ID',
              controller: _utrController,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Submit Request',
              onPressed: _submitRequest,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
