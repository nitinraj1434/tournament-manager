import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/services/database_service.dart';

class TournamentParticipantsScreen extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentParticipantsScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${tournament.title} Participants'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: tournament.participants.isEmpty
          ? const Center(
              child: Text(
                'No participants yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tournament.participants.length,
              itemBuilder: (context, index) {
                final userId = tournament.participants[index];
                return FutureBuilder<UserModel?>(
                  future: dbService.getUser(userId).first,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        child: ListTile(title: Text('Loading...')),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox.shrink();
                    }

                    final user = snapshot.data!;
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? NetworkImage(user.photoUrl)
                              : null,
                          backgroundColor: AppColors.primary,
                          child: user.photoUrl.isEmpty
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Game Name: ${user.gameName.isNotEmpty ? user.gameName : 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Game ID: ${user.gameUid.isNotEmpty ? user.gameUid : 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
