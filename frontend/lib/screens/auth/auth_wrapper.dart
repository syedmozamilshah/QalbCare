import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import '../../main.dart';
import '../../widgets/islamic_loading_indicator.dart';
import '../../utils/constants.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: LoadingStates.authenticating(),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // Get user's display name or use default
          final userName = snapshot.data!.displayName ?? 'User';
          // Save user name to storage for faster access
          return FutureBuilder(
            future: _saveUserNameToStorage(userName),
            builder: (context, storageSnapshot) {
              return ChatScreen(userName: userName);
            },
          );
        }

        // User is not logged in, check if they've seen onboarding
        return FutureBuilder<bool>(
          future: authService.hasSeenOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: LoadingStates.general('Loading...'),
              );
            }

            // Show onboarding if not seen, otherwise show login/signup flow
            if (onboardingSnapshot.data == true) {
              // User has seen onboarding, go to login screen
              return const LoginScreen();
            } else {
              // User hasn't seen onboarding, show it
              return const OnboardingScreen();
            }
          },
        );
      },
    );
  }

  Future<void> _saveUserNameToStorage(String userName) async {
    final storageService = StorageService();
    await storageService.saveUserName(userName);
  }
}
