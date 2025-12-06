import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/screens/admin/admin_dashboard_screen.dart';
import 'package:turnament/screens/home_screen.dart';
import 'package:turnament/screens/my_tournaments_screen.dart';
import 'package:turnament/screens/profile_screen.dart';
import 'package:turnament/screens/wallet_screen.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/widgets/lighting_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() {
    final user = _auth.currentUser;
    if (user != null) {
      _dbService.getUser(user.uid).listen((userModel) {
        if (mounted && userModel != null) {
          setState(() {
            _isAdmin = userModel.role == 'admin';
          });
        }
      });
    }
  }

  List<Widget> get _screens {
    final screens = <Widget>[
      const HomeScreen(),
      const MyTournamentsScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];
    if (_isAdmin) {
      screens.add(const AdminDashboardScreen());
    }
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure index is valid when switching roles
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                bottom: 20,
                top: 12,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildNavItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems() {
    final items = [
      LightingButton(
        icon: Icons.home_rounded,
        label: 'Home',
        isSelected: _currentIndex == 0,
        onTap: () => setState(() => _currentIndex = 0),
      ),
      LightingButton(
        icon: Icons.emoji_events_rounded,
        label: 'My Games',
        isSelected: _currentIndex == 1,
        onTap: () => setState(() => _currentIndex = 1),
      ),
      LightingButton(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
        isSelected: _currentIndex == 2,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      LightingButton(
        icon: Icons.person_rounded,
        label: 'Profile',
        isSelected: _currentIndex == 3,
        onTap: () => setState(() => _currentIndex = 3),
      ),
    ];

    if (_isAdmin) {
      items.add(
        LightingButton(
          icon: Icons.admin_panel_settings_rounded,
          label: 'Admin',
          isSelected: _currentIndex == 4,
          onTap: () => setState(() => _currentIndex = 4),
        ),
      );
    }

    return items;
  }
}
