import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';
import '../../widgets/islamic_decorations.dart';
import '../../assets/avatars.dart';
import '../../assets/blue_gem.dart';
import '../../widgets/islamic_loading_indicator.dart';
import '../../services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _selectedAvatar = 'man2'; // Default avatar
  int _gemPoints = 0;
  UserProfile? _userProfile;
  bool _azkarNotificationsEnabled = true;
  bool _muhasibaNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data()!;
          _userProfile = UserProfile.fromMap(data);
          
          setState(() {
            _nameController.text = _userProfile?.fullName ?? '';
            _emailController.text = _userProfile?.email ?? user.email ?? '';
            _whatsappController.text = _userProfile?.whatsappNumber ?? '';
            _selectedAvatar = data['selectedAvatar'] ?? 'man2';
            _gemPoints = _userProfile?.gemPoints ?? 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load user data');
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'whatsappNumber': _whatsappController.text.trim(),
          'selectedAvatar': _selectedAvatar,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to save profile');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['man2', 'woman2'].map((avatarId) => _buildAvatarOption(avatarId)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String avatarId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = avatarId;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedAvatar == avatarId 
                ? AppColors.primaryGreen 
                : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: CircleAvatar(
          radius: 40,
          child: AvatarSvg(avatarId: avatarId, size: 60),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveUserData,
          ),
        ],
      ),
      body: _isLoading
          ? LoadingStates.loadingProfile()
          : IslamicBackground(
              patternOpacity: 0.05,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                            child: AvatarSvg(avatarId: _selectedAvatar, size: 120),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: FloatingActionButton.small(
                              onPressed: _showAvatarSelection,
                              backgroundColor: AppColors.primaryGreen,
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Profile Fields
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _whatsappController,
                              decoration: const InputDecoration(
                                labelText: 'WhatsApp Number',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Gem Points Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text(
                              'Your Spiritual Progress',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const BlueGemSvg(size: 100),
                            const SizedBox(height: 16),
                            Text(
                              '$_gemPoints Points',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Earn 10 points for each Muhasiba completion\nand 50 points for daily Qalb State assessment',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Notification Settings Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Notification Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Azkar Notifications Toggle
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.notifications_active,
                                  color: AppColors.primaryGreen,
                                ),
                                title: const Text(
                                  'Azkar Reminders',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Get reminded for morning (7:00 AM) and evening (6:30 PM) Azkar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Switch(
                                  value: _azkarNotificationsEnabled,
                                  onChanged: (value) async {
                                    await _toggleAzkarNotifications(value);
                                  },
                                  activeColor: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Muhasiba Notifications Toggle
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.secondaryGold.withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.self_improvement,
                                  color: AppColors.secondaryGold,
                                ),
                                title: const Text(
                                  'Muhasiba Reminders',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Get reminded for daily self-reflection at 9:30 PM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Switch(
                                  value: _muhasibaNotificationsEnabled,
                                  onChanged: (value) async {
                                    await _toggleMuhasibaNotifications(value);
                                  },
                                  activeColor: AppColors.secondaryGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _toggleAzkarNotifications(bool enabled) async {
    setState(() {
      _azkarNotificationsEnabled = enabled;
    });
    if (enabled) {
      await NotificationService.requestNotificationPermissions();
      await NotificationService.scheduleAzkarNotifications();
    } else {
      await NotificationService.cancelNotification(10); // Morning Azkar
      await NotificationService.cancelNotification(11); // Evening Azkar
    }
    if (mounted) {
      final message = enabled ? 'Azkar notifications enabled' : 'Azkar notifications disabled';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  Future<void> _toggleMuhasibaNotifications(bool enabled) async {
    setState(() {
      _muhasibaNotificationsEnabled = enabled;
    });
    if (enabled) {
      await NotificationService.requestNotificationPermissions();
      await NotificationService.scheduleMuhasibaReminder();
    } else {
      await NotificationService.cancelNotification(12); // Muhasiba
    }
    if (mounted) {
      final message = enabled ? 'Muhasiba notifications enabled' : 'Muhasiba notifications disabled';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.secondaryGold,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}
