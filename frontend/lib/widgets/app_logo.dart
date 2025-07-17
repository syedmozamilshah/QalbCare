import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A reusable widget for displaying the QalbCare logo consistently across the app
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool isCircular;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showShadow = true,
    this.isCircular = true,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final actualPadding = padding ?? EdgeInsets.all(size * 0.15);
    
    Widget logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        color: backgroundColor ?? Colors.white,
        borderRadius: isCircular ? null : BorderRadius.circular(size * 0.1),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: size * 0.15,
                  offset: Offset(0, size * 0.05),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: actualPadding,
        child: Image.asset(
          'lib/assets/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );

    return logoWidget;
  }
}

/// A simplified logo widget for smaller sizes
class AppLogoSimple extends StatelessWidget {
  final double size;

  const AppLogoSimple({
    super.key,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'lib/assets/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Animated logo widget for splash screens and loading states
class AppLogoAnimated extends StatefulWidget {
  final double size;
  final Duration animationDuration;
  final bool autoStart;

  const AppLogoAnimated({
    super.key,
    this.size = 120,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.autoStart = true,
  });

  @override
  State<AppLogoAnimated> createState() => _AppLogoAnimatedState();
}

class _AppLogoAnimatedState extends State<AppLogoAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    if (widget.autoStart) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  void startAnimation() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AppLogo(
              size: widget.size,
              showShadow: true,
              isCircular: true,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
