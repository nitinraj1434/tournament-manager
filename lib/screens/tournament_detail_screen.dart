import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/screens/profile_screen.dart';
import 'package:turnament/widgets/custom_button.dart';

class TournamentDetailScreen extends StatefulWidget {
  final TournamentModel tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isJoining = false;

  void _joinTournament() async {
    setState(() => _isJoining = true);
    try {
      await _dbService.joinTournament(
        widget.tournament.id,
        _auth.currentUser!.uid,
        widget.tournament.entryFee,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Joined successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Game ID and Name')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Missing Details'),
              content: const Text(
                'Please update your Game ID and Game Name in your profile to join tournaments.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: const Text('Go to Profile'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.tournament.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tournament.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.gamepad,
                    'Game',
                    widget.tournament.gameType,
                  ),
                  _buildInfoRow(
                    Icons.map,
                    'Map',
                    widget.tournament.map.isNotEmpty
                        ? widget.tournament.map
                        : 'TBD',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('MMM d, yyyy').format(widget.tournament.date),
                  ),
                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    widget.tournament.time,
                  ),
                  _buildInfoRow(
                    Icons.people,
                    'Slots',
                    '${widget.tournament.slots}',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Rules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.tournament.rules,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prize Pool',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${widget.tournament.prize}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Entry Fee',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${widget.tournament.entryFee}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (widget.tournament.participants.contains(
                    _auth.currentUser?.uid,
                  )) ...[
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Room Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.vpn_key,
                            'Room ID',
                            widget.tournament.gameId.isNotEmpty
                                ? widget.tournament.gameId
                                : 'Not set',
                          ),
                          _buildInfoRow(
                            Icons.lock,
                            'Password',
                            widget.tournament.password.isNotEmpty
                                ? widget.tournament.password
                                : 'Not set',
                          ),
                          const Divider(color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text(
                            'Participants: ${widget.tournament.participants.length} / ${widget.tournament.slots}',
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Already Joined',
                      onPressed: () {},
                      color: Colors.grey,
                    ),
                  ] else if (widget.tournament.slots <= 0) ...[
                    CustomButton(
                      text: 'Tournament Full',
                      onPressed: () {},
                      color: Colors.red,
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Join Tournament',
                      onPressed: _joinTournament,
                      isLoading: _isJoining,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
