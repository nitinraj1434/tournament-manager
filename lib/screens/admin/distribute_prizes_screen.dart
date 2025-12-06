import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/entry_model.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/services/database_service.dart';

class DistributePrizesScreen extends StatefulWidget {
  final TournamentModel tournament;

  const DistributePrizesScreen({super.key, required this.tournament});

  @override
  State<DistributePrizesScreen> createState() => _DistributePrizesScreenState();
}

class _DistributePrizesScreenState extends State<DistributePrizesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final Map<String, TextEditingController> _killsControllers = {};
  final Map<String, TextEditingController> _prizeControllers = {};
  final Map<String, bool> _loadingStates = {};

  @override
  void dispose() {
    for (var controller in _killsControllers.values) {
      controller.dispose();
    }
    for (var controller in _prizeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _distributePrize(String userId, String entryId) async {
    final killsText = _killsControllers[userId]?.text ?? '0';
    final prizeText = _prizeControllers[userId]?.text ?? '0';

    final kills = int.tryParse(killsText) ?? 0;
    final prize = double.tryParse(prizeText) ?? 0.0;

    if (prize < 0 || kills < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid values entered')));
      return;
    }

    setState(() {
      _loadingStates[userId] = true;
    });

    try {
      await _dbService.distributePrize(
        widget.tournament.id,
        userId,
        prize,
        kills,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prize distributed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStates[userId] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Distribute Prizes'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: StreamBuilder<List<EntryModel>>(
        stream: _dbService.getTournamentParticipants(widget.tournament.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No participants found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final entries = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              // Initialize controllers if not exists
              if (!_killsControllers.containsKey(entry.userId)) {
                _killsControllers[entry.userId] = TextEditingController(
                  text: entry.kills.toString(),
                );
              }
              if (!_prizeControllers.containsKey(entry.userId)) {
                _prizeControllers[entry.userId] = TextEditingController(
                  text: entry.winnings.toString(),
                );
              }

              return FutureBuilder<UserModel?>(
                future: _dbService.getUser(entry.userId).first,
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final user = userSnapshot.data!;
                  final isLoading = _loadingStates[entry.userId] ?? false;
                  final isCompleted = entry.status == 'completed';

                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isCompleted
                          ? const BorderSide(color: Colors.green, width: 1)
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: user.photoUrl.isNotEmpty
                                    ? NetworkImage(user.photoUrl)
                                    : null,
                                backgroundColor: AppColors.primary,
                                child: user.photoUrl.isEmpty
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Game ID: ${user.gameUid}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _killsControllers[entry.userId],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Kills',
                                    labelStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _prizeControllers[entry.userId],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Prize',
                                    labelStyle: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                    prefixText: AppConstants.currencySymbol,
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _distributePrize(
                                      entry.userId,
                                      entry.entryId,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted
                                    ? Colors.grey[800]
                                    : AppColors.primary,
                                foregroundColor: isCompleted
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isCompleted
                                          ? 'Update Prize'
                                          : 'Send Prize',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
