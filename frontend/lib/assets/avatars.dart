import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';

class AvatarSvg extends StatelessWidget {
  final String avatarId;
  final double size;
  final Color? color;

  const AvatarSvg({
    super.key,
    required this.avatarId,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'lib/assets/$avatarId.svg',
        width: size,
        height: size,
        colorFilter: color != null 
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        // Fallback for missing files
        placeholderBuilder: (context) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen.withOpacity(0.1),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: Icon(
            Icons.person,
            size: size * 0.6,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}

// Available avatar options using the SVG files
Map<String, String> avatarOptions = {
  'man2': 'Man',
  'woman2': 'Woman',
};

// List of available avatar IDs
List<String> availableAvatars = ['man2', 'woman2'];
