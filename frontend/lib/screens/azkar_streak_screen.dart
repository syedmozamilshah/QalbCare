import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/widgets/islamic_decorations.dart';
import 'package:qalbcare/services/notification_service.dart';

class AzkarStreakScreen extends StatefulWidget {
  const AzkarStreakScreen({super.key});

  @override
  State<AzkarStreakScreen> createState() => _AzkarStreakScreenState();
}

class _AzkarStreakScreenState extends State<AzkarStreakScreen> with TickerProviderStateMixin {
  final List<String> azkar = [
    "سُبْحَانَ اللَّهِ ×3",
    "الْحَمْدُ لِلَّهِ ×3",
    "لَا إِلٰهَ إِلَّا اللَّهُ ×3",
    "اللَّهُ أَكْبَرُ ×3",
    "أَسْتَغْفِرُ اللَّهَ ×3",
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ×3",
    "سُبْحَانَ اللَّهِ الْعَظِيمِ ×3",
    "لَا إِلَـٰهَ إِلَّا أَنتَ، سُبْحَانَكَ، إِنِّي كُنتُ مِنَ الظَّالِمِينَ ×3",
    "اللَّهُمَّ صَلِّ عَلَىٰ سَيِّدِنَا مُحَمَّدٍ ٱلنَّبِيِّ ٱلْأُمِّيِّ وَعَلَىٰ آلِهِ وَصَحْبِهِ وَسَلِّمْ ×3",
    "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ ×3",
  ];

  List<bool> _checked = List<bool>.filled(10, false);
  bool _canSubmit = false;
  int _streak = 0;
  late AnimationController _streakAnimation;
  bool _morningCompleted = false;
  bool _eveningCompleted = false;
  bool _isEveningTime = false;

  @override
  void initState() {
    super.initState();
    _streakAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadStreakData();
    _checkStreakValidity();
  }

  @override
  void dispose() {
    _streakAnimation.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt('azkar_streak') ?? 0;
    final today = DateTime.now();
    final todayString = NotificationService.formatDate(today);
    
    // Check if morning or evening was completed today
    final morningCompleted = prefs.getBool('azkar_morning_$todayString') ?? false;
    final eveningCompleted = prefs.getBool('azkar_evening_$todayString') ?? false;
    
    // Determine if it's evening time (after 2 PM)
    final isEveningTime = today.hour >= 14;
    
    setState(() {
      _streak = streak;
      _morningCompleted = morningCompleted;
      _eveningCompleted = eveningCompleted;
      _isEveningTime = isEveningTime;
    });
  }

  Future<void> _handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = NotificationService.formatDate(today);
    
    // Determine if this is morning or evening submission
    final isEveningSubmission = _isEveningTime;
    
    // Check if we need to increment streak (only once per day)
    final lastStreakDate = prefs.getString('azkar_last_streak_date');
    final shouldIncrementStreak = lastStreakDate != todayString;
    
    // Update completion status
    if (isEveningSubmission) {
      await prefs.setBool('azkar_evening_$todayString', true);
      setState(() {
        _eveningCompleted = true;
      });
    } else {
      await prefs.setBool('azkar_morning_$todayString', true);
      setState(() {
        _morningCompleted = true;
      });
    }
    
    // Increment streak if this is the first completion of the day
    if (shouldIncrementStreak) {
      setState(() {
        _streak++;
      });
      await prefs.setInt('azkar_streak', _streak);
      await prefs.setString('azkar_last_streak_date', todayString);
    }
    
    setState(() {
      _checked = List<bool>.filled(10, false);
      _canSubmit = false;
    });
    
    await prefs.setString('azkar_last_submit', todayString);
    
    _streakAnimation.forward().then((_) {
      _streakAnimation.reverse();
    });
    
    if (mounted) {
      final completionType = isEveningSubmission ? 'Evening' : 'Morning';
      final bothCompleted = _morningCompleted && _eveningCompleted;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bothCompleted 
                ? 'Excellent! Both morning and evening Azkar completed! 🌟'
                : '$completionType Azkar completed! ${bothCompleted ? '' : (isEveningSubmission ? 'Morning' : 'Evening')} Azkar remaining 🌙',
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _updateCheckbox(bool? value, int index) {
    setState(() {
      _checked[index] = value ?? false;
      _canSubmit = _checked.every((element) => element) && _canSubmitForCurrentTime();
    });
  }
  
  bool _canSubmitForCurrentTime() {
    // Allow submission if the appropriate time slot hasn't been completed
    if (_isEveningTime) {
      return !_eveningCompleted;
    } else {
      return !_morningCompleted;
    }
  }

  Future<void> _checkStreakValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSubmit = prefs.getString('azkar_last_submit');
    final today = DateTime.now();
    final todayString = NotificationService.formatDate(today);

    if (lastSubmit == null || lastSubmit != todayString) {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayString = NotificationService.formatDate(yesterday);
      
      if (lastSubmit != yesterdayString) {
        // Reset streak if more than one day missed
        setState(() {
          _streak = 0;
        });
        await prefs.setInt('azkar_streak', 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Azkar Streak',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedBuilder(
              animation: _streakAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _streakAnimation.value * 0.3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '$_streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: IslamicBackground(
        patternOpacity: 0.05,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '✨ Daily Azkar ✨',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEveningTime 
                          ? 'Evening Azkar - Complete all 10 adhkār'
                          : 'Morning Azkar - Complete all 10 adhkār',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _morningCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🌅 Morning',
                            style: TextStyle(
                              fontSize: 12,
                              color: _morningCompleted ? Colors.white : AppColors.textSecondary,
                              fontWeight: _morningCompleted ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _eveningCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🌇 Evening',
                            style: TextStyle(
                              fontSize: 12,
                              color: _eveningCompleted ? Colors.white : AppColors.textSecondary,
                              fontWeight: _eveningCompleted ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _streakAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + _streakAnimation.value * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Current Streak: $_streak days',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Progress indicator
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${_checked.where((c) => c).length}/${azkar.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${((_checked.where((c) => c).length / azkar.length) * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _checked.where((c) => c).length / azkar.length,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              
              // Azkar List
              Expanded(
                child: ListView.builder(
                  itemCount: azkar.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _checked[index] ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
                        border: Border.all(
                          color: _checked[index] ? AppColors.primaryGreen : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _checked[index],
                                onChanged: (value) => _updateCheckbox(value, index),
                                activeColor: AppColors.primaryGreen,
                                checkColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 24),
                                child: Text(
                                  azkar[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _checked[index] ? AppColors.primaryGreen : AppColors.textPrimary,
                                    decoration: _checked[index] ? TextDecoration.lineThrough : null,
                                    height: 1.3,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Submit Button
              Container(
                margin: const EdgeInsets.only(top: 20),
                height: 56,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit ? AppColors.primaryGreen : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    elevation: _canSubmit ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
                    ),
                  ),
                  child: Text(
                    _canSubmit 
                        ? (_isEveningTime ? 'Complete Evening Azkar ✨' : 'Complete Morning Azkar ✨')
                        : (_canSubmitForCurrentTime() 
                            ? 'Complete all Azkar to submit'
                            : (_isEveningTime ? 'Evening Azkar already completed today' : 'Morning Azkar already completed today')),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

