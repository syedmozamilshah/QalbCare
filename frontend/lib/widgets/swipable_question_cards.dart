import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:qalbcare/models/muhasiba_model.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/widgets/muhasiba_card.dart';

class SwipableQuestionCards extends StatefulWidget {
  final List<MuhasibaQuestion> questions;
  final Function(String, bool) onSwipe;
  final VoidCallback onFinish;
  final Color primaryColor;
  final bool showHeader;

  const SwipableQuestionCards({
    super.key,
    required this.questions,
    required this.onSwipe,
    required this.onFinish,
    this.primaryColor = AppColors.primaryGreen,
    this.showHeader = true,
  });

  @override
  State<SwipableQuestionCards> createState() => _SwipableQuestionCardsState();
}

class _SwipableQuestionCardsState extends State<SwipableQuestionCards> {
  final CardSwiperController controller = CardSwiperController();
  int _currentIndex = 0;

  // Keep consistent primary green color for all cards
  Color get _cardColor => AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Enhanced responsive sizing
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;
    
    final headerPadding = _getHeaderPadding(isMobile, isTablet, isDesktop, isSmallMobile);
    final titleFontSize = _getTitleFontSize(isMobile, isTablet, isDesktop, isSmallMobile);
    final countFontSize = _getCountFontSize(isMobile, isTablet, isDesktop, isSmallMobile);
    final progressBarHeight = _getProgressBarHeight(isMobile, isTablet, isDesktop, isSmallMobile);
    final cardsPadding = _getCardsPadding(isMobile, isTablet, isDesktop, isSmallMobile);
    final bottomPadding = _getBottomPadding(isMobile, isTablet, isDesktop, isSmallMobile);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Muhasiba',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Clean header section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: headerPadding,
                child: Column(
                  children: [
                    Text(
                      'Daily Self-Assessment',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : isTablet ? 20 : isMobile ? 16 : 14),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 18 : isTablet ? 16 : 14,
                          vertical: isDesktop ? 10 : isTablet ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${_currentIndex + 1} of ${widget.questions.length}',
                          style: TextStyle(
                            fontSize: countFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                    ),
                    SizedBox(height: isDesktop ? 24 : isTablet ? 20 : isMobile ? 16 : 14),
                    // Clean progress bar
                    Container(
                      width: double.infinity,
                      height: progressBarHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(progressBarHeight / 2),
                        color: Colors.grey[200],
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentIndex + 1) / widget.questions.length,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(progressBarHeight / 2),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen,
                                    AppColors.primaryGreen.withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if ((_currentIndex + 1) / widget.questions.length > 0.15)
                            Positioned(
                              left: isDesktop ? 16 : isTablet ? 14 : 12,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Text(
                                  '${((_currentIndex + 1) / widget.questions.length * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 14 : isTablet ? 13 : 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Enhanced cards section with better background and stacking
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF8F9FA),
                      Color(0xFFF1F3F4),
                    ],
                  ),
                ),
                child: Padding(
                  padding: cardsPadding,
                  child: CardSwiper(
                    controller: controller,
                    cardsCount: widget.questions.length,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      // Handle the swipe
                      final isYes = direction == CardSwiperDirection.right;
                      widget.onSwipe(widget.questions[previousIndex].id, isYes);

                      setState(() {
                        _currentIndex = currentIndex ?? widget.questions.length;
                      });

                      // If we've swiped the last card, call onFinish immediately
                      if (currentIndex == null ||
                          previousIndex == widget.questions.length - 1) {
                        // This means we've swiped the last card - call onFinish immediately
                        widget.onFinish();
                      }

                      return true;
                    },
                    numberOfCardsDisplayed: _getNumberOfCards(isMobile, isTablet, isDesktop, isSmallMobile),
                    backCardOffset: _getBackCardOffset(isMobile, isTablet, isDesktop, isSmallMobile),
                    padding: const EdgeInsets.all(0),
                    scale: _getCardScale(isMobile, isTablet, isDesktop, isSmallMobile),
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                      final question = widget.questions[index];

                      return MuhasibaCard(
                        question: question.question,
                        color: _cardColor,
                        icon: question.icon,
                        rotationFactor: percentThresholdX.toDouble(),
                        slideFactor: percentThresholdY.toDouble(),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Enhanced bottom instruction section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: bottomPadding,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEnhancedInstructionItem(
                      icon: Icons.close,
                      color: const Color(0xFFE53E3E),
                      label: 'Swipe Left for No',
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isSmallMobile: isSmallMobile,
                    ),
                    _buildEnhancedInstructionItem(
                      icon: Icons.check,
                      color: AppColors.primaryGreen,
                      label: 'Swipe Right for Yes',
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isSmallMobile: isSmallMobile,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnhancedInstructionItem({
    required IconData icon,
    required Color color,
    required String label,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isSmallMobile,
  }) {
    final iconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isMobile ? 24.0 : 20.0;
    final containerSize = isDesktop ? 68.0 : isTablet ? 64.0 : isMobile ? 56.0 : 48.0;
    final fontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isMobile ? 14.0 : 12.0;
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 20 : isTablet ? 18 : 16,
          horizontal: isDesktop ? 16 : isTablet ? 14 : 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.8),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  icon == Icons.close ? '👈' : '👉',
                  style: TextStyle(
                    fontSize: iconSize * 0.8,
                  ),
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 16 : isTablet ? 14 : 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Enhanced responsive helper methods
  EdgeInsets _getHeaderPadding(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return const EdgeInsets.all(28.0);
    if (isTablet) return const EdgeInsets.all(24.0);
    if (isSmallMobile) return const EdgeInsets.all(16.0);
    return const EdgeInsets.all(20.0);
  }
  
  double _getTitleFontSize(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 32.0;
    if (isTablet) return 28.0;
    if (isSmallMobile) return 22.0;
    return 24.0;
  }
  
  double _getCountFontSize(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 20.0;
    if (isTablet) return 18.0;
    if (isSmallMobile) return 14.0;
    return 16.0;
  }
  
  double _getProgressBarHeight(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 14.0;
    if (isTablet) return 12.0;
    if (isSmallMobile) return 8.0;
    return 10.0;
  }
  
  EdgeInsets _getCardsPadding(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0);
    if (isSmallMobile) return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);
    return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0);
  }
  
  EdgeInsets _getBottomPadding(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 28.0, vertical: 18.0);
    if (isSmallMobile) return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
  }
  
  int _getNumberOfCards(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    if (isSmallMobile) return 2;
    return 3;
  }
  
  Offset _getBackCardOffset(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return const Offset(0, 16);
    if (isTablet) return const Offset(0, 14);
    if (isSmallMobile) return const Offset(0, 8);
    return const Offset(0, 10);
  }
  
  double _getCardScale(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 0.95;
    if (isTablet) return 0.93;
    if (isSmallMobile) return 0.88;
    return 0.90;
  }
}
