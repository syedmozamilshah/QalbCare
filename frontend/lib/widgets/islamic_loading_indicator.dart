import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qalbcare/utils/constants.dart';

// Math constants and functions
const double pi = math.pi;
double cos(double x) => math.cos(x);
double sin(double x) => math.sin(x);

class IslamicLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showQuote;
  final Duration animationDuration;

  const IslamicLoadingIndicator({
    super.key,
    this.message,
    this.size = 80.0,
    this.primaryColor = AppColors.primaryGreen,
    this.secondaryColor = AppColors.secondaryGold,
    this.showQuote = true,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<IslamicLoadingIndicator> createState() => _IslamicLoadingIndicatorState();
}

class _IslamicLoadingIndicatorState extends State<IslamicLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _islamicQuotes = [
    "In the remembrance of Allah, hearts find peace",
    "And Allah is with the patient",
    "With hardship comes ease",
    "Trust in Allah's timing",
    "Allah does not burden a soul beyond its capacity",
    "And it is He who created the heavens and earth in truth",
    "Indeed, with Allah is your provision",
    "Allah is sufficient for us and He is the best guardian",
  ];

  String? _currentQuote;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
    _fadeController.repeat(reverse: true);

    // Initialize quote
    if (widget.showQuote) {
      _currentQuote = _islamicQuotes[_quoteIndex];
      _startQuoteRotation();
    }
  }

  void _startQuoteRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _islamicQuotes.length;
          _currentQuote = _islamicQuotes[_quoteIndex];
        });
        _startQuoteRotation();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizing based on available space
          final availableHeight = constraints.maxHeight;
          final availableWidth = constraints.maxWidth;
          
          // Determine if we're in a constrained space
          final isConstrained = availableHeight < 120 || availableWidth < 200;
          
          // Adjust sizes for constrained spaces
          final effectiveSize = isConstrained 
              ? math.min(widget.size, availableHeight * 0.6) 
              : widget.size;
          
          final spacing = isConstrained ? 4.0 : 24.0;
          final messageFontSize = isConstrained ? 12.0 : 16.0;
          final quoteFontSize = isConstrained ? 10.0 : 14.0;
          final horizontalPadding = isConstrained ? 8.0 : 32.0;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Islamic Star
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      return AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: CustomPaint(
                                  size: Size(effectiveSize, effectiveSize),
                                  painter: IslamicStarPainter(
                                    primaryColor: widget.primaryColor,
                                    secondaryColor: widget.secondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              
              if (widget.message != null || (widget.showQuote && _currentQuote != null))
                SizedBox(height: spacing),
              
              // Loading message
              if (widget.message != null)
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Text(
                      widget.message!,
                      style: TextStyle(
                        fontSize: messageFontSize,
                        fontWeight: FontWeight.w500,
                        color: widget.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: isConstrained ? 1 : 2,
                    ),
                  ),
                ),
              
              if (widget.message != null && widget.showQuote && _currentQuote != null)
                SizedBox(height: spacing * 0.5),
              
              // Islamic quote (always show when enabled)
              if (widget.showQuote && _currentQuote != null)
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(_currentQuote),
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"$_currentQuote"',
                            style: TextStyle(
                              fontSize: quoteFontSize,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: isConstrained ? 2 : 3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- Quran',
                            style: TextStyle(
                              fontSize: isConstrained ? quoteFontSize - 1 : quoteFontSize - 2,
                              fontWeight: FontWeight.w600,
                              color: widget.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class IslamicStarPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  const IslamicStarPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Outer glow
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(center, radius * 0.9, glowPaint);
    
    // Main star
    final starPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    final innerStarPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw 8-pointed star
    _drawEightPointedStar(canvas, center, radius * 0.7, starPaint);
    _drawEightPointedStar(canvas, center, radius * 0.4, innerStarPaint);
    _drawEightPointedStar(canvas, center, radius * 0.7, borderPaint);
    
    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.25, innerCirclePaint);
    
    // Draw dots around the star
    _drawDecorativeDots(canvas, center, radius * 0.85);
  }

  void _drawEightPointedStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 8;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi) / points;
      final currentRadius = i.isEven ? radius : radius * 0.5;
      final x = center.dx + currentRadius * cos(angle);
      final y = center.dy + currentRadius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDecorativeDots(Canvas canvas, Offset center, double radius) {
    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * pi) / 12;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Predefined loading indicators for specific use cases
class LoadingStates {
  static Widget authenticating() => const IslamicLoadingIndicator(
    message: "Authenticating...",
    showQuote: true,
  );
  
  static Widget loadingProfile() => const IslamicLoadingIndicator(
    message: "Loading your profile...",
    showQuote: false,
  );
  
  static Widget savingData() => const IslamicLoadingIndicator(
    message: "Saving your progress...",
    showQuote: false,
    size: 60,
  );
  
  static Widget loadingChatHistory() => const IslamicLoadingIndicator(
    message: "Loading your conversations...",
    showQuote: true,
  );
  
  static Widget processingMuhasiba() => const IslamicLoadingIndicator(
    message: "Processing your self-reflection...",
    showQuote: true,
  );
  
  static Widget analyzingHeartState() => const IslamicLoadingIndicator(
    message: "Analyzing your spiritual state...",
    showQuote: true,
  );
  
  static Widget connecting() => const IslamicLoadingIndicator(
    message: "Connecting to server...",
    showQuote: false,
    size: 60,
  );
  
  static Widget general([String? message]) => IslamicLoadingIndicator(
    message: message ?? "Please wait...",
    showQuote: message == null,
  );
}

// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color overlayColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.overlayColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor,
            child: LoadingStates.general(message),
          ),
      ],
    );
  }
}
