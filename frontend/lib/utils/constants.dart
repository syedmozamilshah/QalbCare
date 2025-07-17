import 'package:flutter/material.dart';

// App Colors
class AppColors {
  // Primary colors
  static const Color primaryGreen = Color(0xFF1F7A68); // Slightly adjusted green
  static const Color secondaryGold = Color(0xFFD4B86A);
  static const Color accentBlue = Color(0xFF5C8A9D); // Islamic blue
  
  // Background colors
  static const Color background = Color(0xFFF8F7F2); // Soft cream background
  static const Color cardBackground = Color(0xFFFFFFF9); // Slightly off-white
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D2D2D); // Softer than black
  static const Color textSecondary = Color(0xFF6D6D6D); // Medium gray
  static const Color textLight = Color(0xFFF8F7F2); // For dark backgrounds
  
  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0); // Light gray border
  
  // Accent colors
  static const Color accentRed = Color(0xFFC45E5E); // Soft Islamic red
  static const Color accentTeal = Color(0xFF5EBFB5); // Teal accent
  
  // Gradient colors
  static const List<Color> primaryGradient = [primaryGreen, Color(0xFF0A5D4D)];
  static const List<Color> goldGradient = [secondaryGold, Color(0xFFBFA055)];
}

// Islamic UI Constants
class IslamicUI {
  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  
  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;
  
  // Islamic patterns - SVG paths for decorative elements
  static const String starPatternPath = "M10 0L13.09 6.58L20 7.24L15 12.08L16.18 19L10 15.77L3.82 19L5 12.08L0 7.24L6.91 6.58L10 0Z";
  static const String flowerPatternPath = "M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.6 0 12 0zm0 22c-5.5 0-10-4.5-10-10S6.5 2 12 2s10 4.5 10 10-4.5 10-10 10z";
}

// Heart State Questions - Signs of a spiritually dead heart
class HeartQuestions {
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'shame_after_sin',
      'question': 'Do you feel ashamed after committing a sin?',
      'options': [
        'Yes, I feel deep remorse and seek forgiveness immediately',
        'Sometimes, depending on the sin',
        'Rarely, I usually justify my actions',
        'No, I don\'t feel much guilt after sinning'
      ],
      'correctOptionIndex': 0,
    },
    {
      'id': 'quran_pleasure',
      'question': 'Do you feel pleasure when listening to or reciting the Quran?',
      'options': [
        'Yes, it brings me deep peace and joy',
        'Sometimes, when I\'m in the right mood',
        'Rarely, I mostly listen out of obligation',
        'No, I don\'t feel much when hearing Quran'
      ],
      'correctOptionIndex': 0,
    },
    {
      'id': 'prayer_burden',
      'question': 'Does prayer feel like a burden or chore to you?',
      'options': [
        'No, prayer is the comfort of my eyes',
        'Sometimes it feels heavy, but I still do it',
        'Often it feels like an obligation I must fulfill',
        'Yes, I often delay or avoid prayers'
      ],
      'correctOptionIndex': 0,
    },
    {
      'id': 'sin_enjoyment',
      'question': 'Do you find enjoyment or satisfaction in sinful acts?',
      'options': [
        'No, sins disturb my peace and I avoid them',
        'Sometimes I enjoy them but feel guilty later',
        'I often enjoy them but try to repent afterwards',
        'Yes, I find pleasure in many sinful activities'
      ],
      'correctOptionIndex': 0,
    },
    {
      'id': 'religious_company',
      'question': 'How do you feel around righteous, religious people?',
      'options': [
        'I love their company and feel inspired',
        'I feel comfortable but sometimes judged',
        'I feel uncomfortable and out of place',
        'I actively avoid such people'
      ],
      'correctOptionIndex': 0,
    },
    {
      'id': 'death_reminder',
      'question': 'How do reminders of death and afterlife affect you?',
      'options': [
        'They motivate me to do good and repent',
        'They make me thoughtful but don\'t change much',
        'They make me uncomfortable and anxious',
        'I ignore or dismiss such thoughts'
      ],
      'correctOptionIndex': 0,
    },
    {
      'id': 'islamic_knowledge',
      'question': 'How interested are you in learning about Islam?',
      'options': [
        'Very interested, I actively seek knowledge',
        'Moderately interested, I learn occasionally',
        'Slightly interested, only when convenient',
        'Not interested, I know enough already'
      ],
      'correctOptionIndex': 0,
    },
  ];
}

// 7-Day Heart Healing Journey Tasks
class HeartHealingJourney {
  static final Map<int, List<String>> dailyTasks = {
    1: [
      'Recite Durood (Salawat) on Prophet Muhammad (PBUH) at least 100 times',
      'Listen to one complete Surah of the Quran with focus and reflection',
      'Spend 10 minutes in silent dhikr (remembrance of Allah)',
      'Imagine you are on your deathbed - what would you regret not doing?',
      'Make sincere Tawbah (repentance) for your sins',
      'Read about the signs of a living heart vs dead heart',
      'Avoid one specific sin you regularly commit today'
    ],
    2: [
      'Perform Tahajjud (night prayer) even if just 2 rakats',
      'Recite Istighfar (seeking forgiveness) 300 times',
      'Read about the punishments of the grave',
      'Give charity, even if it\'s a small amount',
      'Call a family member you haven\'t spoken to in a while',
      'Spend 15 minutes reading Quran with translation',
      'Practice gratitude by listing 10 blessings Allah gave you'
    ],
    3: [
      'Fast today (if physically able) or skip one meal',
      'Visit a graveyard and reflect on death (if possible)',
      'Listen to recitation of Surah Al-Mulk',
      'Perform extra voluntary prayers (Nafl)',
      'Help someone in need without expecting anything in return',
      'Study the names and attributes of Allah (Asma ul Husna)',
      'Imagine standing before Allah on the Day of Judgment'
    ],
    4: [
      'Wake up early for Fajr and stay awake until sunrise',
      'Recite Surah Al-Kahf (or part of it) with reflection',
      'Make dua for all Muslims around the world',
      'Forgive someone who has wronged you',
      'Read about the biography of Prophet Muhammad (PBUH)',
      'Spend time in nature and reflect on Allah\'s creation',
      'Imagine what your family will do when you die'
    ],
    5: [
      'Perform I\'tikaf (spiritual retreat) for a few hours if possible',
      'Read the entire Surah Yaseen',
      'Make a list of sins you want to quit permanently',
      'Practice dhikr while walking or doing daily activities',
      'Learn and practice a new Islamic supplication (dua)',
      'Reflect on how short this life is compared to the afterlife',
      'Spend quality time with righteous friends or family'
    ],
    6: [
      'Give up a worldly pleasure you enjoy for the sake of Allah',
      'Read about the descriptions of Paradise and Hell',
      'Perform extra acts of worship throughout the day',
      'Make sincere dua for guidance and a sound heart',
      'Practice controlling your anger and tongue today',
      'Imagine what questions you\'ll be asked in the grave',
      'Study the lives of the righteous companions (Sahaba)'
    ],
    7: [
      'Make a sincere commitment to continue good deeds after today',
      'Plan your daily routine to include more worship',
      'Write down lessons learned during this 7-day journey',
      'Thank Allah for guiding you through this healing process',
      'Set specific spiritual goals for the coming month',
      'Share your experience with someone who might benefit',
      'Make a heartfelt dua for a permanently reformed heart'
    ],
  };

  static String getDayTitle(int day) {
    switch (day) {
      case 1:
        return 'Day 1: Awakening';
      case 2:
        return 'Day 2: Repentance';
      case 3:
        return 'Day 3: Remembrance';
      case 4:
        return 'Day 4: Forgiveness';
      case 5:
        return 'Day 5: Devotion';
      case 6:
        return 'Day 6: Purification';
      case 7:
        return 'Day 7: Commitment';
      default:
        return 'Day $day: Healing';
    }
  }

  static String getDayDescription(int day) {
    switch (day) {
      case 1:
        return 'Begin your journey by awakening your heart to Allah\'s remembrance';
      case 2:
        return 'Seek Allah\'s forgiveness and turn back to Him with sincere repentance';
      case 3:
        return 'Remember death and the afterlife to put things in perspective';
      case 4:
        return 'Cleanse your heart through forgiveness and following the Prophet\'s way';
      case 5:
        return 'Deepen your devotion through increased worship and reflection';
      case 6:
        return 'Purify your heart by leaving sins and embracing righteousness';
      case 7:
        return 'Commit to a life of continuous spiritual growth and heart maintenance';
      default:
        return 'Continue your journey of healing and spiritual growth';
    }
  }
}

// Recommended Islamic Deeds
class IslamicDeeds {
  static final List<String> heartHealingDeeds = [
    'Recite Quran for at least 15 minutes',
    'Perform Dhikr (remembrance of Allah) for 10 minutes',
    'Pray two extra rakats with full concentration',
    'Give charity, even if a small amount',
    'Visit a sick person or help someone in need',
    'Seek knowledge about Islam for 15 minutes',
    'Reflect on death and the hereafter for 5 minutes',
    'Make sincere dua (supplication) for yourself and others',
    'Perform istighfar (seeking forgiveness) 100 times',
    'Fast for one day if you are able',
    'Pray Tahajjud (night prayer)',
    'Maintain ties with family members you haven\'t spoken to recently',
    'Avoid backbiting and negative speech for the entire day',
    'Read about the life of Prophet Muhammad (peace be upon him)',
    'Perform wudu (ablution) and maintain it throughout the day',
  ];
}

