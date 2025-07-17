import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../widgets/islamic_decorations.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/islamic_loading_indicator.dart';
import '../../main.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = false;
  bool _canResendEmail = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _loading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload(); // Refresh emailVerified status
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Navigate to main app
        if (mounted) {
          final userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userName: userName,
              ),
            ),
          );
        }
      } else {
        setState(() => _loading = false);
        
        // Show message that email is not verified yet
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please check your inbox and click the verification link.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        
        setState(() {
          _canResendEmail = false;
          _resendCountdown = 60;
        });

        // Start countdown timer
        _startResendTimer();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent! Check your inbox.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const AppLogo(size: 120, showShadow: true, isCircular: true),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Verify Your Email',
                    style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,color: AppColors.textPrimary,),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Email verification message
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.email_outlined, size: 64, color: AppColors.primaryGreen),
                        const SizedBox(height: 16),
                        const Text(
                          'We\'ve sent a verification link to:',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email ?? 'your email address',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Please check your inbox and click the verification link to continue.',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Don\'t forget to check your spam folder if you can\'t find the email.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_loading)
                    const Column(
                      children: [
                        IslamicLoadingIndicator(),
                        SizedBox(height: 16),
                        Text('Checking verification status...', style: TextStyle(color: AppColors.textSecondary),),
                      ],
                    )
                  else
                    Column(
                      children: [
                        // Check verification button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: IslamicButton(
                            text: 'I Have Verified My Email',
                            onPressed: _checkEmailVerification,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resend email button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _canResendEmail ? _resendVerificationEmail : null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _canResendEmail 
                                  ? 'Resend Verification Email'
                                  : 'Resend in ${_resendCountdown}s',
                              style: TextStyle(color: _canResendEmail ? AppColors.primaryGreen : AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // Sign out and try different email
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text('Use Different Email', style: TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline,),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
