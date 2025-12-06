import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/screens/admin/distribute_prizes_screen.dart';
import 'package:turnament/screens/admin/select_winner_screen.dart';
import 'package:turnament/services/database_service.dart';
import 'package:intl/intl.dart';

class FinishMatchListScreen extends StatelessWidget {
  const FinishMatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finish Matches'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: StreamBuilder<List<TournamentModel>>(
        stream: dbService.getTournaments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter for published tournaments that are not yet completed
          final tournaments =
              snapshot.data?.where((t) => t.status == 'published').toList() ??
              [];

          if (tournaments.isEmpty) {
            return const Center(
              child: Text(
                'No active matches to finish',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    tournament.title,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tournament.gameType} • ${DateFormat('MMM d, h:mm a').format(tournament.date)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        'Prize: ${AppConstants.currencySymbol}${tournament.prize}',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select Action'),
                        content: const Text(
                          'Do you want to select a single winner or distribute prizes based on kills?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SelectWinnerScreen(
                                    tournament: tournament,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Single Winner'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DistributePrizesScreen(
                                    tournament: tournament,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Distribute Prizes'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
