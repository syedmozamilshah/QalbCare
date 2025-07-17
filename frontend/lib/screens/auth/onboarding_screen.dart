import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_logo.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final LiquidController liquidController = LiquidController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: _buildPages(),
            liquidController: liquidController,
            onPageChangeCallback: (activePageIndex) {
              setState(() {
                currentPage = activePageIndex;
              });
            },
            waveType: WaveType.liquidReveal,
            slideIconWidget: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            enableSideReveal: true,
            disableUserGesture: false,
          ),
          if (currentPage < 2)
            Positioned(
              bottom: 50,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  liquidController.animateToPage(
                    page: currentPage + 1,
                    duration: 300,
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          if (currentPage == 2)
            Positioned(
              bottom: 50,
              right: 20,
              child: FloatingActionButton(
                onPressed: _finishOnboarding,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.check,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _buildOnboardingPage(
        backgroundColor: AppColors.primaryGreen,
        title: 'Welcome to QalbCare',
        subtitle: 'Your Personal Islamic Therapist',
        description: 'Connect with Islamic wisdom and find peace through guided conversations and spiritual support.',
        icon: const AppLogo(
          size: 120,
          showShadow: true,
          isCircular: true,
        ),
      ),
      _buildOnboardingPage(
        backgroundColor: AppColors.secondaryGold,
        title: 'Spiritual Guidance',
        subtitle: 'Personalized Islamic Therapy',
        description: 'Get personalized advice rooted in Islamic teachings. Our AI therapist understands your spiritual journey.',
        icon: const Icon(
          Icons.mosque,
          size: 120,
          color: Colors.white,
        ),
      ),
      _buildOnboardingPage(
        backgroundColor: const Color(0xFF2E7D32),
        title: 'Heart Assessment',
        subtitle: 'Know Your Spiritual State',
        description: 'Take regular assessments to understand your spiritual heart condition and track your progress.',
        icon: const Icon(
          Icons.favorite,
          size: 120,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildOnboardingPage({
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required String description,
    required Widget icon,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: icon,
              ),
              const SizedBox(height: 40),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    await _authService.markOnboardingSeen();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignupScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    // LiquidController doesn't need explicit disposal
    super.dispose();
  }
}
