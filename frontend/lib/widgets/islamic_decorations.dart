import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qalbcare/utils/constants.dart';

/// A collection of Islamic decorative widgets for use throughout the app

/// A container with Islamic-styled decoration
class IslamicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final bool showPattern;
  final Color patternColor;
  final double patternOpacity;

  const IslamicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.borderRadius = 16.0,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.secondaryGold,
    this.elevation = 2.0,
    this.showPattern = true,
    this.patternColor = AppColors.primaryGreen,
    this.patternOpacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showPattern)
              Positioned.fill(
                child: Opacity(
                  opacity: patternOpacity,
                  child: CustomPaint(
                    painter: IslamicPatternPainter(
                      color: patternColor,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// A decorative divider with Islamic styling
class IslamicDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double thickness;
  final double indent;
  final double endIndent;

  const IslamicDivider({
    super.key,
    this.height = 24.0,
    this.color = AppColors.secondaryGold,
    this.thickness = 1.0,
    this.indent = 16.0,
    this.endIndent = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Divider(
              color: color.withOpacity(0.5),
              thickness: thickness,
              indent: indent,
              endIndent: endIndent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDividerOrnament(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerOrnament() {
    return Container(
      width: 40,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: thickness),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// A background with Islamic geometric patterns
class IslamicBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color patternColor;
  final double patternOpacity;

  const IslamicBackground({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.patternColor = AppColors.primaryGreen,
    this.patternOpacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: patternOpacity,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: patternColor,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A custom painter for Islamic geometric patterns
class IslamicPatternPainter extends CustomPainter {
  final Color color;

  const IslamicPatternPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double tileSize = size.width / 8;

    // Draw the geometric pattern
    for (double x = 0; x < size.width; x += tileSize) {
      for (double y = 0; y < size.height; y += tileSize) {
        _drawIslamicTile(canvas, Offset(x, y), tileSize, paint);
      }
    }
  }

  void _drawIslamicTile(
      Canvas canvas, Offset position, double size, Paint paint) {
    // Draw an eight-pointed star pattern
    final path = Path();

    // Center of the tile
    final center = Offset(position.dx + size / 2, position.dy + size / 2);

    // Draw the star
    final outerRadius = size / 2;
    final innerRadius = size / 5;

    for (int i = 0; i < 8; i++) {
      final outerAngle = i * 2 * 3.14159 / 8;
      final innerAngle = (i + 0.5) * 2 * 3.14159 / 8;

      final outerPoint = Offset(
        center.dx + outerRadius * cos(outerAngle),
        center.dy + outerRadius * sin(outerAngle),
      );

      final innerPoint = Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }

      path.lineTo(innerPoint.dx, innerPoint.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// A header with Islamic styling
class IslamicHeader extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final Color backgroundColor;
  final Color borderColor;
  final double height;
  final Widget? leading;
  final Widget? trailing;

  const IslamicHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.backgroundColor = AppColors.primaryGreen,
    this.borderColor = AppColors.secondaryGold,
    this.height = 60.0,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const defaultTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: borderColor, width: 2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // Colors.black.withOpacity(0.1)
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leading != null) leading!,
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: titleStyle ?? defaultTitleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A button with Islamic styling
class IslamicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showPattern;
  final double elevation;
  final IconData? icon;

  const IslamicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.primaryGreen,
    this.textColor = Colors.white,
    this.borderColor = AppColors.secondaryGold,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    this.showPattern = true,
    this.elevation = 2.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final Color finalBackgroundColor =
        isEnabled ? backgroundColor : backgroundColor.withOpacity(0.6);
    final Color finalTextColor =
        isEnabled ? textColor : textColor.withOpacity(0.6);
    final Color finalBorderColor =
        isEnabled ? borderColor : borderColor.withOpacity(0.6);

    return Material(
      color: Colors.transparent,
      elevation: isEnabled ? elevation : 0,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: finalBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: finalBorderColor, width: 1.5),
          ),
          child: Stack(
            children: [
              if (showPattern)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius - 1.5),
                    child: const Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: IslamicPatternPainter(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: finalTextColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: finalTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
