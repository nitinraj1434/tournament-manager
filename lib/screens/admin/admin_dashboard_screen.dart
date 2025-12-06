import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/screens/admin/finish_match_list_screen.dart';
import 'package:turnament/screens/admin/tournament_management_screen.dart';
import 'package:turnament/screens/admin/user_management_screen.dart';
import 'package:turnament/screens/admin/wallet_requests_screen.dart';
import 'package:turnament/screens/admin/withdrawal_requests_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(context, 'Manage Users', Icons.people, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserManagementScreen()),
            );
          }),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            'Manage Tournaments',
            Icons.sports_esports,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TournamentManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            'Wallet Requests',
            Icons.account_balance_wallet,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletRequestsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildAdminCard(context, 'Withdrawal Requests', Icons.money_off, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WithdrawalRequestsScreen(),
              ),
            );
          }),
          const SizedBox(height: 16),
          _buildAdminCard(context, 'Finish Matches', Icons.emoji_events, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinishMatchListScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
