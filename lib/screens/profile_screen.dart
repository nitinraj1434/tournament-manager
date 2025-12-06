import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/services/auth_service.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/screens/admin/admin_dashboard_screen.dart';
import 'package:turnament/screens/about_us_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:turnament/services/storage_service.dart';
import 'package:turnament/widgets/custom_button.dart';
import 'package:turnament/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _gameUidController = TextEditingController();
  final _gameNameController = TextEditingController();
  File? _imageFile;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initial load will be handled by StreamBuilder
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _gameUidController.dispose();
    _gameNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _updateProfile(UserModel user) async {
    final name = _nameController.text.trim();
    // Photo URL is handled via upload now
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();
    final address = _addressController.text.trim();
    final gameUid = _gameUidController.text.trim();
    final gameName = _gameNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);
    setState(() => _isLoading = true);
    try {
      String photoUrl = user.photoUrl;
      if (_imageFile != null) {
        photoUrl = await _storageService.uploadProfileImage(
          user.uid,
          _imageFile!,
        );
      } else if (_photoUrlController.text.isNotEmpty) {
        photoUrl = _photoUrlController.text.trim();
      }

      await _dbService.updateUserProfile(
        uid: user.uid,
        name: name,
        photoUrl: photoUrl,
        phoneNumber: phone,
        bio: bio,
        address: address,
        gameUid: gameUid,
        gameName: gameName,
      );
      await _auth.currentUser?.updateDisplayName(name);
      if (photoUrl.isNotEmpty) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }
      setState(() {
        _isEditing = false;
        _imageFile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: _dbService.getUser(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _authService.signOut(),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'User data not found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _authService.signOut(),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          }
          final user = snapshot.data!;

          if (!_isEditing) {
            _nameController.text = user.name;
            _photoUrlController.text = user.photoUrl;
            _phoneController.text = user.phoneNumber;
            _bioController.text = user.bio;
            _addressController.text = user.address;
            _gameUidController.text = user.gameUid;
            _gameNameController.text = user.gameName;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surface,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (user.photoUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          user.photoUrl,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child: (_imageFile == null && user.photoUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  CustomTextField(label: 'Name', controller: _nameController),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Photo URL',
                    controller: _photoUrlController,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Address',
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Game UID',
                    controller: _gameUidController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Game Name',
                    controller: _gameNameController,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ] else ...[
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (user.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.phoneNumber,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                  ],
                  if (user.address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.address,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (user.gameUid.isNotEmpty || user.gameName.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (user.gameUid.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Game UID',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  user.gameUid,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (user.gameUid.isNotEmpty &&
                              user.gameName.isNotEmpty)
                            const SizedBox(height: 8),
                          if (user.gameName.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Game Name',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  user.gameName,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Wallet Balance',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                  trailing: Text(
                    '${AppConstants.currencySymbol}${user.walletBalance}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Matches', '${user.matchesPlayed}'),
                      _buildVerticalDivider(),
                      _buildStatItem('Won', '${user.matchesWon}'),
                      _buildVerticalDivider(),
                      _buildStatItem(
                        'Earnings',
                        '${AppConstants.currencySymbol}${user.totalEarnings}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (user.role == 'admin') ...[
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Admin Dashboard',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () async {
                    final Uri url = Uri.parse('https://wa.me/919798365598');
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not launch WhatsApp'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'About Us',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),
                if (_isEditing)
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: () => _updateProfile(user),
                    isLoading: _isLoading,
                  )
                else
                  CustomButton(
                    text: 'Edit Profile',
                    onPressed: () => setState(() => _isEditing = true),
                    color: AppColors.surface,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.textSecondary.withValues(alpha: 0.2),
    );
  }
}
