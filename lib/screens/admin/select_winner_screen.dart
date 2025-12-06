import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/services/database_service.dart';

class SelectWinnerScreen extends StatefulWidget {
  final TournamentModel tournament;

  const SelectWinnerScreen({super.key, required this.tournament});

  @override
  State<SelectWinnerScreen> createState() => _SelectWinnerScreenState();
}

class _SelectWinnerScreenState extends State<SelectWinnerScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedWinnerId;
  String? _selectedWinnerName;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _finishMatch() async {
    if (_selectedWinnerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a winner')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid winning amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.finishTournament(
        widget.tournament.id,
        _selectedWinnerId!,
        amount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match finished successfully!')),
        );
        Navigator.pop(context); // Pop SelectWinnerScreen
        Navigator.pop(
          context,
        ); // Pop FinishMatchListScreen (optional, depending on flow)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Winner'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tournament: ${widget.tournament.title}',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Winning Amount',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixText: '${AppConstants.currencySymbol} ',
                    prefixStyle: const TextStyle(color: AppColors.textPrimary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.textSecondary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedWinnerName != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Winner: $_selectedWinnerName',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedWinnerId = null;
                              _selectedWinnerName = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.tournament.participants.isEmpty
                ? const Center(
                    child: Text(
                      'No participants in this tournament',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.tournament.participants.length,
                    itemBuilder: (context, index) {
                      final userId = widget.tournament.participants[index];
                      return FutureBuilder<UserModel?>(
                        future: _dbService.getUser(userId).first,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const SizedBox.shrink();
                          }
                          final user = snapshot.data!;
                          final isSelected = _selectedWinnerId == user.uid;

                          return Card(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Game ID: ${user.gameUid}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedWinnerId = user.uid;
                                  _selectedWinnerName = user.name;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _finishMatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text(
                  'FINISH MATCH & DISTRIBUTE PRIZE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
      ),
    );
  }
}
