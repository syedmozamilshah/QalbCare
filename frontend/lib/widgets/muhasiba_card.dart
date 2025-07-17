import 'package:flutter/material.dart';
import 'dart:math' as math;

class MuhasibaCard extends StatelessWidget {
  final String question;
  final Color color;
  final IconData icon;
  final double rotationFactor;
  final double slideFactor;

  const MuhasibaCard({
    super.key,
    required this.question,
    required this.color,
    required this.icon,
    this.rotationFactor = 0,
    this.slideFactor = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Responsive sizing
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;
    
    final cardHeight = _getCardHeight(screenHeight, isMobile, isTablet, isDesktop, isSmallMobile);
    final cardMargin = _getCardMargin(screenWidth, isMobile, isTablet, isDesktop, isSmallMobile);
    final iconSize = _getIconSize(isMobile, isTablet, isDesktop, isSmallMobile);
    final fontSize = _getFontSize(isMobile, isTablet, isDesktop, isSmallMobile);
    final bannerFontSize = _getBannerFontSize(isMobile, isTablet, isDesktop, isSmallMobile);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Transform(
          transform: Matrix4.identity()
            ..rotateZ(rotationFactor * 0.03)
            ..translate(slideFactor * 8.0, 0.0),
          child: Container(
            margin: cardMargin,
            height: cardHeight,
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 420 : isTablet ? 380 : 340,
              maxHeight: constraints.maxHeight * 0.88,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Clean background with subtle overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Main card content
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 32.0 : isTablet ? 28.0 : 24.0),
                  child: Column(
                    children: [
                      // Top instruction banner
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : isTablet ? 20 : 16,
                          vertical: isDesktop ? 12 : isTablet ? 10 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '👆',
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                              ),
                            ),
                            SizedBox(width: isDesktop ? 8 : 6),
                            Text(
                              'Swipe Right for Yes, Left for No',
                              style: TextStyle(
                                fontSize: bannerFontSize,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isDesktop ? 40 : isTablet ? 35 : 30),
                      
                      // Icon section
                      Container(
                        width: iconSize * 1.6,
                        height: iconSize * 1.6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: _buildCleanIcon(iconSize, icon),
                        ),
                      ),
                      
                      SizedBox(height: isDesktop ? 40 : isTablet ? 35 : 30),
                      
                      // Question text
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                              ),
                              child: Text(
                                question,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
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
        );
      },
    );
  }
  
  // Helper methods for responsive design
  double _getCardHeight(double screenHeight, bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return math.min(screenHeight * 0.75, 720);
    if (isTablet) return math.min(screenHeight * 0.72, 680);
    if (isSmallMobile) return math.min(screenHeight * 0.68, 580);
    return math.min(screenHeight * 0.70, 650);
  }
  
  EdgeInsets _getCardMargin(double screenWidth, bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
    if (isSmallMobile) return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
  }
  
  double _getIconSize(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 75.0;
    if (isTablet) return 70.0;
    if (isSmallMobile) return 55.0;
    return 60.0;
  }
  
  double _getFontSize(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 36.0;
    if (isTablet) return 32.0;
    if (isSmallMobile) return 26.0;
    return 28.0;
  }
  
  double _getBannerFontSize(bool isMobile, bool isTablet, bool isDesktop, bool isSmallMobile) {
    if (isDesktop) return 16.0;
    if (isTablet) return 15.0;
    if (isSmallMobile) return 12.0;
    return 13.0;
  }
  
  Widget _buildCleanIcon(double iconSize, IconData fallbackIcon) {
    // Special handling for family icon
    if (fallbackIcon == Icons.family_restroom || question.toLowerCase().contains('family')) {
      return Icon(
        Icons.groups,
        size: iconSize,
        color: Colors.white,
      );
    }
    
    // For other questions, use the provided icon
    return Icon(
      fallbackIcon,
      size: iconSize,
      color: Colors.white,
    );
  }
}

