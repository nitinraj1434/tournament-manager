import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/screens/admin/create_edit_tournament_screen.dart';
import 'package:turnament/screens/admin/tournament_participants_screen.dart';
import 'package:turnament/services/database_service.dart';
import 'package:intl/intl.dart';

class TournamentManagementScreen extends StatelessWidget {
  const TournamentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Tournaments'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateEditTournamentScreen(),
                ),
              );
            },
          ),
        ],
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tournaments found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tournament = snapshot.data![index];
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
                        'Slots: ${tournament.slots} • Fee: ${AppConstants.currencySymbol}${tournament.entryFee}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.people,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TournamentParticipantsScreen(
                                tournament: tournament,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tournament.status == 'published'
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tournament.status.toUpperCase(),
                          style: TextStyle(
                            color: tournament.status == 'published'
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateEditTournamentScreen(tournament: tournament),
                      ),
                    );
                  },
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TournamentParticipantsScreen(
                          tournament: tournament,
                        ),
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
