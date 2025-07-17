import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qalbcare/firebase_options.dart';
import 'package:qalbcare/screens/heart_state/heart_state_screen.dart';
import 'package:qalbcare/screens/muhasiba/muhasiba_screen.dart';
import 'package:qalbcare/screens/vapi_call_screen.dart';
import 'package:qalbcare/screens/splash_screen.dart';
import 'package:qalbcare/screens/settings/settings_screen.dart';
import 'package:qalbcare/screens/auth/login_screen.dart';
import 'package:qalbcare/screens/azkar_streak_screen.dart';
import 'package:qalbcare/services/notification_service.dart';
import 'package:qalbcare/services/storage_service.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/utils/theme.dart';
import 'package:qalbcare/widgets/islamic_decorations.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';
import 'package:qalbcare/widgets/app_logo.dart';
import 'package:qalbcare/assets/avatars.dart';
import 'package:qalbcare/assets/blue_gem.dart';
import 'package:qalbcare/services/api_service.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'package:qalbcare/services/environment_service.dart';
import 'package:qalbcare/models/chat_model.dart';
import 'package:qalbcare/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize environment variables
    await EnvironmentService.initialize();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize notifications
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
      // Continue without notifications if they fail
    }
    
  } catch (e) {
    debugPrint('App initialization error: $e');
    // Show error screen or fallback
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      title: 'QalbCare',
      theme: IslamicTheme.lightTheme,
      initialRoute: '/',
      routes: {
      '/': (context) => const SplashScreen(),
        '/azkar-streak': (context) => const AzkarStreakScreen(),
        '/muhasiba': (context) => const MuhasibaScreen(),
      },
    );
  }
}


class ChatScreen extends StatefulWidget {
  final String userName;

  const ChatScreen({super.key, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  
  ChatSession? _currentSession;
  List<ChatSession> _chatHistory = [];
  String? _selectedAvatar = 'man2';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUserAvatar();
    _addMessage(
      ChatMessage(
        text: 'Hello ${widget.userName}! How can I help you today?',
        sender: 'Mustafa',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _loadChatHistory() async {
    try {
      final sessions = await _firestoreService.getChatSessions();
      setState(() {
        _chatHistory = sessions;
      });
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _loadUserAvatar() async {
    try {
      // First try to get from Firebase user profile
      final userProfile = await _loadUserProfile();
      if (userProfile?.selectedAvatar != null) {
        setState(() {
          _selectedAvatar = userProfile!.selectedAvatar;
        });
        // Also save to local storage for fast access
        final storageService = StorageService();
        await storageService.saveUserAvatar(_selectedAvatar!);
        return;
      }
      
      // Fallback to local storage
      final storageService = StorageService();
      final localAvatar = await storageService.getUserAvatar();
      setState(() {
        _selectedAvatar = localAvatar ?? 'man2';
      });
    } catch (e) {
      debugPrint('Error loading user avatar: $e');
      setState(() {
        _selectedAvatar = 'man2';
      });
    }
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentSession = null;
    });
    
    _addMessage(
      ChatMessage(
        text: 'Hello ${widget.userName}! How can I help you today?',
        sender: 'Mustafa',
        timestamp: DateTime.now(),
      ),
    );
  }

  void _loadChatSession(ChatSession session) {
    setState(() {
      _messages.clear();
      _currentSession = session;
      _messages.addAll(session.messages);
    });
    _scrollToBottom();
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: AvatarSvg(avatarId: _selectedAvatar ?? 'man2', size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // New Chat Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startNewChat();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Azkar Streak
          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text('Azkar Streak'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/azkar-streak');
            },
          ),
          // Muhasiba
          ListTile(
            leading: const Icon(Icons.self_improvement,
                color: AppColors.secondaryGold),
            title: const Text('Muhasiba'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MuhasibaScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // Chat History
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Recent Chats',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: _chatHistory.isEmpty
                ? const Center(
                    child: Text(
                      'No chat history yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final session = _chatHistory[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                        title: Text(
                          session.title.isNotEmpty ? session.title : session.generateTitle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          session.getLastMessagePreview(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _loadChatSession(session);
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteChatSession(session.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 16),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                          child: const Icon(
                            Icons.more_vert,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChatSession(String sessionId) async {
    try {
      await _firestoreService.deleteChatSession(sessionId);
      await _loadChatHistory();
    } catch (e) {
      debugPrint('Error deleting chat session: $e');
    }
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.trim().isEmpty) return;

    _addMessage(ChatMessage(
        text: text, sender: widget.userName, timestamp: DateTime.now()));
    setState(() {
      _isTyping = true;
    });

    _sendMessage(text);
  }

  Future<void> _sendMessage(String text) async {
    try {
      final response = await _apiService.sendChatMessage(
        'user_${widget.userName.hashCode}',
        widget.userName.split(' ').first, // Extract first name
        text,
      );

      final message = response['message'] as String;
      final emotion = response['emotion'] as String?;

      _addMessage(ChatMessage(
        text: message,
        sender: 'Mustafa',
        timestamp: DateTime.now(),
        emotion: emotion,
      ));
    } catch (e) {
      // Log the actual error for debugging
      print('❌ Error sending message: $e');
      
      String errorMessage = 'Sorry, I\'m having trouble connecting.';

      // Provide more specific error messages
      if (e.toString().contains('connection') || e.toString().contains('Network')) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('Server error')) {
        errorMessage =
            'Server is temporarily unavailable. Please try again in a few moments.';
      } else if (e.toString().contains('Failed to send message')) {
        errorMessage = 'Failed to send message. Server returned an error.';
      } else {
        // For debugging: show the actual error
        errorMessage = 'Error: ${e.toString()}';
      }

      _addMessage(ChatMessage(
        text: errorMessage,
        sender: 'Mustafa',
        timestamp: DateTime.now(),
      ));
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
    
    // Auto-save chat session after adding messages
    _autoSaveChatSession();
  }

  Future<void> _autoSaveChatSession() async {
    if (_messages.length < 2) return; // Don't save until we have at least user message + response
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      if (_currentSession == null) {
        // Create new session
        _currentSession = ChatSession(
          title: '', // Will be generated automatically
          messages: List.from(_messages),
          userId: user.uid,
        );
        await _firestoreService.saveChatSession(_currentSession!);
      } else {
        // Update existing session
        final updatedSession = _currentSession!.copyWith(
          messages: List.from(_messages),
          lastUpdated: DateTime.now(),
        );
        await _firestoreService.updateChatSession(updatedSession);
        _currentSession = updatedSession;
      }
      
      // Refresh chat history
      await _loadChatHistory();
    } catch (e) {
      debugPrint('Error auto-saving chat session: $e');
    }
  }

  void _handleMessageEdit(int index, ChatMessage editedMessage) {
    setState(() {
      _messages[index] = editedMessage;
    });
    
    // If we have a current session, update it
    if (_currentSession != null) {
      final updatedMessages = List<ChatMessage>.from(_messages);
      final updatedSession = _currentSession!.copyWith(
        messages: updatedMessages,
        lastUpdated: DateTime.now(),
      );
      _saveCurrentSession(updatedSession);
    }
  }

  Future<void> _saveCurrentSession(ChatSession session) async {
    try {
      await _firestoreService.updateChatSession(session);
      setState(() {
        _currentSession = session;
      });
      await _loadChatHistory();
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickMessage(String message) {
    _handleSubmitted(message);
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              final storageService = StorageService();
              await storageService.clearUserName();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<UserProfile?>(
          future: _loadUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                content: SizedBox(
                  height: 200,
                  child: LoadingStates.loadingProfile(),
                ),
              );
            }
            
            final userProfile = snapshot.data;
            final selectedAvatar = userProfile?.selectedAvatar ?? 'man2';
            final displayName = userProfile?.fullName ?? widget.userName;
            final email = userProfile?.email ?? 'No email set';
            
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: AvatarSvg(avatarId: selectedAvatar, size: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (userProfile?.gemPoints != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BlueGemSvg(size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${userProfile!.gemPoints} Points',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Profile'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<UserProfile?> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          return UserProfile.fromMap(userDoc.data()!);
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkPointsAndStartVapiCall(BuildContext context) async {
    try {
      final hasPoints = await _firestoreService.hasVapiCallPoints();
      
      if (!mounted) return;
      
      if (hasPoints) {
        await _firestoreService.deductVapiCallPoints();
        
        if (!mounted) return;
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VapiCallScreen(userName: widget.userName),
          ),
        );

        // Note: Removed the automatic point deduction after delay as it should be handled in VapiCallScreen
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.9,
                  maxHeight: screenHeight * 0.8,
                ),
                child: SingleChildScrollView(
                  child: IslamicContainer(
                    backgroundColor: AppColors.cardBackground,
                    borderColor: AppColors.accentRed,
                    elevation: IslamicUI.elevationMedium,
                    borderRadius: IslamicUI.borderRadiusLarge,
                    padding: const EdgeInsets.all(IslamicUI.spacingLarge),
                    margin: const EdgeInsets.all(IslamicUI.spacingMedium),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with gem
                        Container(
                          padding: const EdgeInsets.all(IslamicUI.spacingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const BlueGemSvg(size: 50),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: IslamicUI.spacingMedium),
                        // Title
                        Text(
                          'Insufficient Points',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: IslamicUI.spacingSmall),
                        // Content
                        Text(
                          'You need 100,000 points to use this functionality.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                        ),
                        const SizedBox(height: IslamicUI.spacingSmall),
                        // Additional info
                        Container(
                          padding: const EdgeInsets.all(IslamicUI.spacingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Earn points by completing daily tasks and heart healing activities',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.visible,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: IslamicUI.spacingLarge),
                        // Islamic decorative divider
                        const IslamicDivider(
                          height: 20,
                          color: AppColors.accentRed,
                          thickness: 1.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        const SizedBox(height: IslamicUI.spacingMedium),
                        // Single close button
                        SizedBox(
                          width: double.infinity,
                          child: IslamicButton(
                            text: 'Close',
                            backgroundColor: AppColors.primaryGreen,
                            textColor: Colors.white,
                            borderColor: AppColors.secondaryGold,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error during VAPI call: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use PopScope for Flutter 3.16+
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              AppLogoSimple(
                size: 32,
              ),
              SizedBox(width: 12),
              Text('QalbCare'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              tooltip: 'Talk to Therapist',
              onPressed: () => _checkPointsAndStartVapiCall(context),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HeartStateScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              tooltip: 'Profile',
              onPressed: () {
                _showProfileDialog(context);
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: IslamicBackground(
          patternOpacity: 0.1,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (_, int index) {
                    return ChatBubble(
                      message: _messages[index],
                      isMe: _messages[index].sender == widget.userName,
                      userAvatar: _selectedAvatar,
                      onEdit: (editedMessage) {
                        _handleMessageEdit(index, editedMessage);
                      },
                    );
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mustafa is typing...',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          QuickMessageButton(
                            text: 'How are you?',
                            onPressed: () =>
                                _handleQuickMessage('How are you?'),
                          ),
                          QuickMessageButton(
                            text: 'I feel sad today',
                            onPressed: () =>
                                _handleQuickMessage('I feel sad today'),
                          ),
                          QuickMessageButton(
                            text: 'Tell me about yourself',
                            onPressed: () =>
                                _handleQuickMessage('Tell me about yourself'),
                          ),
                          QuickMessageButton(
                            text: 'I need advice',
                            onPressed: () =>
                                _handleQuickMessage('I need advice'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                hintText: 'Send a message...',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                              ),
                              onSubmitted: _handleSubmitted,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          FloatingActionButton(
                            onPressed: () =>
                                _handleSubmitted(_textController.text),
                            child: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final String? userAvatar;
  final Function(ChatMessage)? onEdit;

  const ChatBubble({
    super.key, 
    required this.message, 
    required this.isMe, 
    this.userAvatar,
    this.onEdit,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.text);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveEdit() {
    if (_editController.text.trim().isNotEmpty && widget.onEdit != null) {
      final editedMessage = widget.message.copyWith(
        text: _editController.text.trim(),
        isEdited: true,
      );
      widget.onEdit!(editedMessage);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEdit() {
    _editController.text = widget.message.text;
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isMe) ...[_buildAvatar()],
          const SizedBox(width: 10),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(widget.isMe ? 20 : 4),
                    bottomRight: Radius.circular(widget.isMe ? 4 : 20),
                  ),
                  color: widget.isMe ? const Color(0xFF007AFF) : Colors.white,
                  border: widget.isMe
                      ? null
                      : Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (_isEditing)
                      Column(
                        children: [
                          TextField(
                            controller: _editController,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: _cancelEdit,
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _saveEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment:
                            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isMe ? Colors.white : AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          if (widget.message.isEdited)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '(edited)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.isMe
                                      ? Colors.white.withOpacity(0.7)
                                      : AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.message.timestamp.hour}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isMe
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (widget.isMe) ...[_buildAvatar()],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.isMe && widget.userAvatar != null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: AvatarSvg(avatarId: widget.userAvatar!, size: 30),
      );
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundColor: widget.isMe ? AppColors.primaryGreen : AppColors.secondaryGold,
      child: Text(
        widget.message.sender.substring(0, 1).toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard();
              },
            ),
            if (widget.isMe && widget.onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _startEditing();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class QuickMessageButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const QuickMessageButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: IslamicButton(
        text: text,
        onPressed: onPressed,
        backgroundColor: AppColors.cardBackground,
        textColor: AppColors.textPrimary,
        borderColor: AppColors.secondaryGold.withOpacity(0.3),
        borderRadius: 18.0,
        elevation: 0.5,
        showPattern: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
