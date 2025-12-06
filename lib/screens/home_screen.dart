import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/screens/tournament_detail_screen.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/widgets/app_logo.dart';
import 'package:turnament/widgets/tournament_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = '';
  String _statusFilter = 'published';
  String _gameTypeFilter = 'all';
  bool _onlyUpcoming = true;
  double _entryFeeCeiling = 1000;
  double _selectedMaxEntryFee = 1000;
  List<String> _gameTypeOptions = ['all'];

  bool get _hasActiveFilters {
    final bool feeFiltered =
        _selectedMaxEntryFee < _entryFeeCeiling && _entryFeeCeiling > 0;
    return _statusFilter != 'published' ||
        _gameTypeFilter != 'all' ||
        !_onlyUpcoming ||
        feeFiltered;
  }

  void _syncFilterSources(List<TournamentModel> tournaments) {
    final types = <String>{'all'};
    double highestFee = 0;
    for (final tournament in tournaments) {
      if (tournament.gameType.isNotEmpty) {
        types.add(tournament.gameType);
      }
      if (tournament.entryFee > highestFee) {
        highestFee = tournament.entryFee;
      }
    }
    final normalizedCeiling = (highestFee == 0 ? 1000 : highestFee)
        .ceilToDouble();
    final typeList = types.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (!listEquals(typeList, _gameTypeOptions) ||
        normalizedCeiling != _entryFeeCeiling) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _gameTypeOptions = typeList;
          _entryFeeCeiling = normalizedCeiling;
          if (_selectedMaxEntryFee > normalizedCeiling) {
            _selectedMaxEntryFee = normalizedCeiling;
          }
        });
      });
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempStatus = _statusFilter;
        String tempGame = _gameTypeFilter;
        double tempMaxFee = _selectedMaxEntryFee;
        bool tempUpcoming = _onlyUpcoming;

        final sliderMax = _entryFeeCeiling <= 0 ? 1000.0 : _entryFeeCeiling;

        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: tempStatus,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'published',
                        child: Text('Published'),
                      ),
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                      DropdownMenuItem(value: 'all', child: Text('All')),
                    ],
                    onChanged: (value) =>
                        modalSetState(() => tempStatus = value ?? 'published'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: tempGame,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Game Type',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    items: _gameTypeOptions
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type == 'all' ? 'All Games' : type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        modalSetState(() => tempGame = value ?? 'all'),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Max Entry Fee: ${AppConstants.currencySymbol}${tempMaxFee.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.onSurface),
                      ),
                      Slider(
                        value: tempMaxFee.clamp(0, sliderMax),
                        min: 0,
                        max: sliderMax,
                        divisions: sliderMax == 0 ? 1 : 20,
                        activeColor: AppColors.primary,
                        label:
                            '${AppConstants.currencySymbol}${tempMaxFee.toStringAsFixed(0)}',
                        onChanged: (value) =>
                            modalSetState(() => tempMaxFee = value),
                      ),
                    ],
                  ),
                  SwitchListTile.adaptive(
                    value: tempUpcoming,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Only show upcoming events',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => modalSetState(() => tempUpcoming = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            modalSetState(() {
                              tempStatus = 'published';
                              tempGame = 'all';
                              tempMaxFee = sliderMax;
                              tempUpcoming = true;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _statusFilter = tempStatus;
                              _gameTypeFilter = tempGame;
                              _selectedMaxEntryFee = tempMaxFee;
                              _onlyUpcoming = tempUpcoming;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeaturedCarousel(List<TournamentModel> tournaments) {
    if (tournaments.isEmpty) return const SizedBox.shrink();
    // Show top 3 tournaments as featured
    final featured = tournaments.take(3).toList();

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final tournament = featured[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: tournament.bannerUrl.isNotEmpty
                    ? CachedNetworkImageProvider(tournament.bannerUrl)
                    : const AssetImage('assets/images/placeholder.jpg')
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tournament.gameType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tournament.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Entry: ${AppConstants.currencySymbol}${tournament.entryFee}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'PUBG', 'Free Fire', 'COD', 'BGMI'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              _gameTypeFilter == (category == 'All' ? 'all' : category);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _gameTypeFilter = category == 'All' ? 'all' : category;
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
              backgroundColor: AppColors.surface,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: const [
            AppLogo(size: 32, showText: false),
            SizedBox(width: 12),
            Text('Tournaments', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters ? AppColors.primary : Colors.white,
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F3460), Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search tournaments...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<TournamentModel>>(
                stream: _dbService.getTournaments(),
                builder: (context, snapshot) {
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

                  _syncFilterSources(snapshot.data!);

                  final now = DateTime.now();
                  final tournaments = snapshot.data!.where((t) {
                    final matchesSearch = t.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                    final matchesStatus = _statusFilter == 'all'
                        ? true
                        : t.status == _statusFilter;
                    final matchesGame =
                        _gameTypeFilter == 'all' ||
                        t.gameType == _gameTypeFilter;
                    final matchesFee =
                        t.entryFee <= _selectedMaxEntryFee ||
                        _entryFeeCeiling == 0;
                    final matchesDate = !_onlyUpcoming || !t.date.isBefore(now);
                    final publishedByDefault = _statusFilter == 'all'
                        ? t.status == 'published'
                        : true;

                    return matchesSearch &&
                        matchesStatus &&
                        matchesGame &&
                        matchesFee &&
                        matchesDate &&
                        publishedByDefault;
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_gameTypeFilter == 'all' &&
                            _searchQuery.isEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Featured',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeaturedCarousel(tournaments),
                          const SizedBox(height: 24),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryChips(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'Search Results'
                                : 'All Tournaments',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (tournaments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No tournaments match your filter',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tournaments.length,
                            itemBuilder: (context, index) {
                              return TournamentCard(
                                tournament: tournaments[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TournamentDetailScreen(
                                        tournament: tournaments[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 80), // Bottom padding
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
