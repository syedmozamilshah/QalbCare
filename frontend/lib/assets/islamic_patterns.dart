import 'package:flutter/material.dart';

/// A collection of Islamic geometric patterns as SVG path strings
/// These can be used with CustomPaint or SVG widgets to create
/// authentic Islamic decorative elements throughout the app
class IslamicPatterns {
  // Eight-pointed star - a common Islamic geometric pattern
  static const String eightPointedStar = """
    <svg viewBox="0 0 100 100">
      <path d="M50 0L61 18L82 7L75 30L100 35L80 50L100 65L75 70L82 93L61 82L50 100L39 82L18 93L25 70L0 65L20 50L0 35L25 30L18 7L39 18L50 0Z" 
            fill="currentColor" />
    </svg>
  """;

  // Geometric arabesque pattern
  static const String arabesque = """
    <svg viewBox="0 0 100 100">
      <path d="M10,30 Q50,0 90,30 Q100,50 90,70 Q50,100 10,70 Q0,50 10,30 Z" 
            fill="none" stroke="currentColor" stroke-width="1" />
      <path d="M30,30 Q50,10 70,30 Q80,50 70,70 Q50,90 30,70 Q20,50 30,30 Z" 
            fill="none" stroke="currentColor" stroke-width="1" />
      <path d="M40,40 Q50,30 60,40 Q65,50 60,60 Q50,70 40,60 Q35,50 40,40 Z" 
            fill="none" stroke="currentColor" stroke-width="1" />
    </svg>
  """;

  // Islamic geometric lattice
  static const String geometricLattice = """
    <svg viewBox="0 0 100 100">
      <path d="M0,0 L100,0 L100,100 L0,100 Z" fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M25,0 L25,100" stroke="currentColor" stroke-width="0.5" />
      <path d="M50,0 L50,100" stroke="currentColor" stroke-width="0.5" />
      <path d="M75,0 L75,100" stroke="currentColor" stroke-width="0.5" />
      <path d="M0,25 L100,25" stroke="currentColor" stroke-width="0.5" />
      <path d="M0,50 L100,50" stroke="currentColor" stroke-width="0.5" />
      <path d="M0,75 L100,75" stroke="currentColor" stroke-width="0.5" />
      <path d="M0,0 L100,100" stroke="currentColor" stroke-width="0.5" />
      <path d="M100,0 L0,100" stroke="currentColor" stroke-width="0.5" />
      <path d="M50,0 L100,50 L50,100 L0,50 Z" fill="none" stroke="currentColor" stroke-width="1" />
    </svg>
  """;

  // Floral arabesque pattern
  static const String floralArabesque = """
    <svg viewBox="0 0 100 100">
      <path d="M50,10 C70,10 90,30 90,50 C90,70 70,90 50,90 C30,90 10,70 10,50 C10,30 30,10 50,10 Z" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M50,20 C65,20 80,35 80,50 C80,65 65,80 50,80 C35,80 20,65 20,50 C20,35 35,20 50,20 Z" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M30,50 C30,40 40,30 50,30 C60,30 70,40 70,50 C70,60 60,70 50,70 C40,70 30,60 30,50 Z" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M50,10 C50,30 50,40 30,50 C50,60 50,70 50,90" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M10,50 C30,50 40,50 50,30 C60,50 70,50 90,50" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M25,25 C40,40 60,40 75,25" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M25,75 C40,60 60,60 75,75" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
    </svg>
  """;

  // Islamic arch pattern
  static const String islamicArch = """
    <svg viewBox="0 0 100 100">
      <path d="M10,80 L10,40 Q50,0 90,40 L90,80 Z" 
            fill="none" stroke="currentColor" stroke-width="1" />
      <path d="M20,80 L20,45 Q50,15 80,45 L80,80" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M30,80 L30,50 Q50,30 70,50 L70,80" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
      <path d="M40,80 L40,55 Q50,45 60,55 L60,80" 
            fill="none" stroke="currentColor" stroke-width="0.5" />
    </svg>
  """;

  // Crescent moon - Islamic symbol
  static const String crescentMoon = """
    <svg viewBox="0 0 100 100">
      <path d="M50,10 A40,40 0 1,1 50,90 A40,40 0 1,1 50,10 Z M50,20 A30,30 0 1,0 50,80 A40,40 0 1,1 50,20 Z" 
            fill="currentColor" />
    </svg>
  """;

  // Mosque dome and minaret silhouette
  static const String mosqueSilhouette = """
    <svg viewBox="0 0 100 100">
      <path d="M10,80 L10,60 L20,60 L20,40 L30,30 L40,40 L40,60 L45,60 L45,80 Z" 
            fill="currentColor" />
      <path d="M50,80 L50,60 Q50,40 70,40 Q90,40 90,60 L90,80 Z" 
            fill="currentColor" />
      <path d="M60,40 Q70,20 80,40" 
            fill="none" stroke="currentColor" stroke-width="1" />
    </svg>
  """;
}

/// A widget that renders Islamic patterns as decorative elements
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final String pattern;

  IslamicPatternPainter({
    required this.color,
    this.opacity = 0.1,
    required this.pattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // This is a simplified implementation
    // In a real app, you would parse the SVG path and draw it
    // For now, we'll just draw a simple pattern based on the size
    
    // Draw a grid pattern
    final spacing = size.width / 10;
    
    for (var i = 0; i < 10; i++) {
      for (var j = 0; j < 10; j++) {
        final rect = Rect.fromLTWH(
          i * spacing,
          j * spacing,
          spacing,
          spacing,
        );
        
        canvas.drawRect(rect, paint);
        
        // Draw diagonal lines
        canvas.drawLine(
          Offset(i * spacing, j * spacing),
          Offset((i + 1) * spacing, (j + 1) * spacing),
          paint,
        );
        
        canvas.drawLine(
          Offset((i + 1) * spacing, j * spacing),
          Offset(i * spacing, (j + 1) * spacing),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color || 
           oldDelegate.opacity != opacity ||
           oldDelegate.pattern != pattern;
  }
}