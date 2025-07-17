import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BlueGemSvg extends StatelessWidget {
  final double size;

  const BlueGemSvg({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        _blueGemSvg,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  static const String _blueGemSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Main gem gradient -->
    <linearGradient id="gemGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#87CEEB"/>
      <stop offset="25%" style="stop-color:#4682B4"/>
      <stop offset="50%" style="stop-color:#1E90FF"/>
      <stop offset="75%" style="stop-color:#0066CC"/>
      <stop offset="100%" style="stop-color:#003D7A"/>
    </linearGradient>
    
    <!-- Highlight gradient -->
    <linearGradient id="highlightGradient" x1="0%" y1="0%" x2="100%" y2="50%">
      <stop offset="0%" style="stop-color:#B0E0E6" stop-opacity="0.8"/>
      <stop offset="50%" style="stop-color:#87CEEB" stop-opacity="0.4"/>
      <stop offset="100%" style="stop-color:#4682B4" stop-opacity="0.1"/>
    </linearGradient>
    
    <!-- Shadow gradient -->
    <radialGradient id="shadowGradient" cx="50%" cy="80%" r="40%">
      <stop offset="0%" style="stop-color:#000000" stop-opacity="0.3"/>
      <stop offset="100%" style="stop-color:#000000" stop-opacity="0.1"/>
    </radialGradient>
    
    <!-- Sparkle gradient -->
    <radialGradient id="sparkleGradient" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#FFFFFF" stop-opacity="0.9"/>
      <stop offset="50%" style="stop-color:#E0F6FF" stop-opacity="0.5"/>
      <stop offset="100%" style="stop-color:#B0E0E6" stop-opacity="0.1"/>
    </radialGradient>
  </defs>
  
  <!-- Drop shadow -->
  <ellipse cx="50" cy="88" rx="25" ry="8" fill="url(#shadowGradient)"/>
  
  <!-- Main gem body -->
  <path d="M 30 35 L 20 50 L 35 80 L 50 85 L 65 80 L 80 50 L 70 35 L 50 15 Z" 
        fill="url(#gemGradient)" 
        stroke="#003D7A" 
        stroke-width="1.5"/>
  
  <!-- Top facet -->
  <path d="M 30 35 L 50 15 L 70 35 L 60 30 L 50 20 L 40 30 Z" 
        fill="url(#highlightGradient)" 
        stroke="#0066CC" 
        stroke-width="1"/>
  
  <!-- Left facet -->
  <path d="M 20 50 L 30 35 L 40 30 L 50 20 L 45 25 L 35 40 L 25 50 Z" 
        fill="#4682B4" 
        stroke="#003D7A" 
        stroke-width="1"/>
  
  <!-- Right facet -->
  <path d="M 80 50 L 70 35 L 60 30 L 50 20 L 55 25 L 65 40 L 75 50 Z" 
        fill="#1E90FF" 
        stroke="#003D7A" 
        stroke-width="1"/>
  
  <!-- Bottom left facet -->
  <path d="M 20 50 L 35 80 L 50 85 L 45 70 L 30 55 Z" 
        fill="#0066CC" 
        stroke="#003D7A" 
        stroke-width="1"/>
  
  <!-- Bottom right facet -->
  <path d="M 80 50 L 65 80 L 50 85 L 55 70 L 70 55 Z" 
        fill="#003D7A" 
        stroke="#001F3D" 
        stroke-width="1"/>
  
  <!-- Center reflection -->
  <path d="M 45 25 L 55 25 L 60 30 L 55 35 L 50 32 L 45 35 L 40 30 Z" 
        fill="url(#sparkleGradient)" 
        opacity="0.7"/>
  
  <!-- Main highlight -->
  <path d="M 40 30 L 50 20 L 55 25 L 50 32 Z" 
        fill="#E0F6FF" 
        opacity="0.8"/>
  
  <!-- Secondary highlight -->
  <path d="M 50 32 L 55 35 L 58 40 L 52 42 Z" 
        fill="#B0E0E6" 
        opacity="0.6"/>
  
  <!-- Sparkle effects -->
  <circle cx="42" cy="28" r="1.5" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="58" cy="32" r="1" fill="#FFFFFF" opacity="0.8"/>
  <circle cx="48" cy="40" r="0.8" fill="#E0F6FF" opacity="0.7"/>
  <circle cx="52" cy="25" r="0.6" fill="#FFFFFF" opacity="0.9"/>
  
  <!-- Star sparkles -->
  <g opacity="0.8">
    <path d="M 35 25 L 36 27 L 38 26 L 37 28 L 39 29 L 37 30 L 38 32 L 36 31 L 35 33 L 34 31 L 32 32 L 33 30 L 31 29 L 33 28 L 32 26 L 34 27 Z" 
          fill="#FFFFFF"/>
  </g>
  
  <g opacity="0.6">
    <path d="M 65 40 L 66 41 L 67 40 L 66 42 L 68 42 L 66 43 L 67 44 L 66 43 L 65 45 L 64 43 L 63 44 L 64 43 L 62 42 L 64 42 L 63 40 L 64 41 Z" 
          fill="#B0E0E6"/>
  </g>
  
  <!-- Rim highlight -->
  <path d="M 30 35 L 70 35 L 65 30 L 35 30 Z" 
        fill="#87CEEB" 
        opacity="0.5"/>
</svg>
  ''';
}
