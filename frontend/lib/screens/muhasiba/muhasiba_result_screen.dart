import 'package:flutter/material.dart';
import 'package:qalbcare/models/muhasiba_model.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/widgets/islamic_decorations.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';

class MuhasibaResultScreen extends StatefulWidget {
  final Map<String, bool> answers;
  final double progressPercentage;
  final List<MuhasibaQuestion> questions;

  const MuhasibaResultScreen({
    super.key,
    required this.answers,
    required this.progressPercentage,
    required this.questions,
  });

  @override
  State<MuhasibaResultScreen> createState() => _MuhasibaResultScreenState();
}

class _MuhasibaResultScreenState extends State<MuhasibaResultScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<DailyRecord> _historyRecords = [];
  int _selectedHistoryDays = 7; // Default to 7 days

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select History Range', 
            style: TextStyle(color: AppColors.primaryGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('1 Day'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(1);
                },
              ),
              ListTile(
                title: const Text('3 Days'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(3);
                },
              ),
              ListTile(
                title: const Text('7 Days'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(7);
                },
              ),
              ListTile(
                title: const Text('30 Days'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(30);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchHistory(int days) async {
    setState(() {
      _selectedHistoryDays = days;
    });

    try {
      final records = await _firestoreService.getMuhasibaResults(lastDays: days);
      setState(() {
        _historyRecords = records;
      });

      // Show bottom sheet with history
      if (mounted) {
        _showHistorySheet();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Muhasiba History ($_selectedHistoryDays days)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _historyRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'No history records found for this period.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _historyRecords.length,
                        itemBuilder: (context, index) {
                          final record = _historyRecords[index];
                          final date = DateTime.parse(record.date);
                          final dateStr = _formatDateDisplay(date);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                'Daily Assessment: $dateStr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Score: ${record.progressPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: IslamicLoadingIndicator(
                                      size: 25.0,
                                      message: null,
                                      showQuote: false,
                                      primaryColor: _getProgressColor(record.progressPercentage),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context); // Close history sheet
                                _showHistoryDetailDialog(record);
                              },
                            )
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDetailDialog(DailyRecord record) {
    final date = DateTime.parse(record.date);
    final dateStr = _formatDateDisplay(date);
    final color = _getProgressColor(record.progressPercentage);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getProgressIcon(record.progressPercentage),
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Muhasiba - $dateStr',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress percentage with progress indicator
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: IslamicLoadingIndicator(
                                size: 60.0,
                                message: null,
                                showQuote: false,
                                primaryColor: color,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getProgressIcon(record.progressPercentage),
                                  size: 30,
                                  color: color,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${record.progressPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getMotivationalMessage(record.progressPercentage),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Assessment information
                _buildDetailRow('Assessment Date', dateStr),
                _buildDetailRow('Total Score', '${record.progressPercentage.toStringAsFixed(1)}%'),
                _buildDetailRow('Questions Answered', '${record.answers.length}'),
                _buildDetailRow('Positive Responses', '${record.answers.values.where((a) => a).length}'),
                
                const SizedBox(height: 16),
                
                // Recommendations section
                const Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRecommendations(record.progressPercentage),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Islamic quote
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getIslamicQuote(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primaryGreen,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    final isSmallMobile = screenWidth < 360;
    
    // Calculate stats for display
    // final answered = answers.length;
    // final correct = answers.values.where((a) => a).length;
    
    final appBarHeight = isDesktop ? 70.0 : isTablet ? 65.0 : 60.0;
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 12.0 : 16.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: IslamicHeader(
          title: 'Muhasiba Results',
          height: appBarHeight,
          backgroundColor: AppColors.primaryGreen,
          borderColor: AppColors.secondaryGold,
          titleStyle: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isDesktop ? 28 : isTablet ? 26 : 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
              size: isDesktop ? 26 : isTablet ? 24 : 22,
            ),
            onPressed: () => _showHistoryDialog(context),
          ),
        ),
      ),
      body: Container(
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
        child: IslamicBackground(
          backgroundColor: Colors.transparent,
          patternColor: AppColors.primaryGreen,
          patternOpacity: 0.02,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced completion card
                  _buildEnhancedCompletionCard(isTablet, isDesktop, isSmallMobile),
                  SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),

                  // Today's detailed progress
                  _buildTodayDetailedProgress(isTablet, isDesktop, isSmallMobile),
                  SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),

                  // Questions breakdown
                  _buildQuestionsBreakdown(isTablet, isDesktop, isSmallMobile),
                  SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),

                  // Motivational section
                  _buildMotivationalSection(isTablet, isDesktop, isSmallMobile),
                  SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }





  String _getIslamicQuote() {
    final quotes = [
      "Verily, with hardship comes ease. - Quran 94:6",
      "Take account of yourselves before you are taken to account. - Umar ibn Al-Khattab",
      "The best of you are those who are best to their families. - Prophet Muhammad ﷺ",
      "The strongest among you is the one who controls his anger. - Prophet Muhammad ﷺ",
      "Be mindful of Allah, and Allah will protect you. - Prophet Muhammad ﷺ",
    ];

    // Return a quote based on the day of the week to keep it consistent for the day
  final dayOfWeek = DateTime.now().weekday;
    return quotes[dayOfWeek % quotes.length];
  }
  
  
  // Utility method for display date formatting (DD/MM/YYYY)
  String _formatDateDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  // Enhanced completion card with better design
  Widget _buildEnhancedCompletionCard(bool isTablet, bool isDesktop, bool isSmallMobile) {
    final answered = widget.answers.length;
    final correct = widget.answers.values.where((a) => a).length;
    final percentage = answered > 0 ? (correct / answered) * 100.0 : 0.0;
    
    final cardPadding = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallMobile ? 16.0 : 20.0;
    final titleSize = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallMobile ? 18.0 : 20.0;
    final scoreSize = isDesktop ? 48.0 : isTablet ? 42.0 : isSmallMobile ? 32.0 : 36.0;
    final iconSize = isDesktop ? 80.0 : isTablet ? 70.0 : isSmallMobile ? 50.0 : 60.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getProgressColor(percentage),
            _getProgressColor(percentage).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getProgressColor(percentage).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getProgressIcon(percentage),
            size: iconSize,
            color: Colors.white,
          ),
          SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),
          Text(
            'Muhasiba Complete!',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 16 : isTablet ? 14 : 12),
          Text(
            percentage.toStringAsFixed(0),
            style: TextStyle(
              fontSize: scoreSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            'SCORE',
            style: TextStyle(
              fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 14),
          Text(
            '$correct out of $answered questions answered positively',
            style: TextStyle(
              fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Today's detailed progress section
  Widget _buildTodayDetailedProgress(bool isTablet, bool isDesktop, bool isSmallMobile) {
    final answered = widget.answers.length;
    final correct = widget.answers.values.where((a) => a).length;
    final percentage = answered > 0 ? (correct / answered) * 100.0 : 0.0;
    
    final titleSize = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 16.0 : 18.0;
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 16.0 : 18.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 14),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: isDesktop ? 12 : isTablet ? 10 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          _getProgressColor(percentage),
                          _getProgressColor(percentage).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 14),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed', 
                  correct.toString(), 
                  AppColors.primaryGreen,
                  isTablet, 
                  isDesktop, 
                  isSmallMobile
                ),
              ),
              SizedBox(width: isDesktop ? 16 : isTablet ? 14 : 12),
              Expanded(
                child: _buildStatCard(
                  'Remaining', 
                  (answered - correct).toString(), 
                  Colors.orange,
                  isTablet, 
                  isDesktop, 
                  isSmallMobile
                ),
              ),
              SizedBox(width: isDesktop ? 16 : isTablet ? 14 : 12),
              Expanded(
                child: _buildStatCard(
                  'Total', 
                  answered.toString(), 
                  AppColors.textSecondary,
                  isTablet, 
                  isDesktop, 
                  isSmallMobile
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Questions breakdown section
  Widget _buildQuestionsBreakdown(bool isTablet, bool isDesktop, bool isSmallMobile) {
    final titleSize = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 16.0 : 18.0;
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 16.0 : 18.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions Breakdown',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 14),
          
          ...widget.questions.map((question) {
            final answered = widget.answers[question.id] ?? false;
            return _buildQuestionItem(
              question.question,
              question.icon,
              answered,
              isTablet,
              isDesktop,
              isSmallMobile,
            );
          }),
        ],
      ),
    );
  }
  
  // Motivational section
  Widget _buildMotivationalSection(bool isTablet, bool isDesktop, bool isSmallMobile) {
    final answered = widget.answers.length;
    final correct = widget.answers.values.where((a) => a).length;
    final percentage = answered > 0 ? (correct / answered) * 100.0 : 0.0;
    
    final titleSize = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 16.0 : 18.0;
    final textSize = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallMobile ? 12.0 : 13.0;
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallMobile ? 16.0 : 18.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFE9ECEF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.secondaryGold,
                size: isDesktop ? 28 : isTablet ? 24 : 20,
              ),
              SizedBox(width: isDesktop ? 12 : isTablet ? 10 : 8),
              Text(
                'Reflection & Guidance',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 14),
          
          Text(
            _getMotivationalMessage(percentage),
            style: TextStyle(
              fontSize: textSize,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: isDesktop ? 16 : isTablet ? 14 : 12),
          
          Text(
            _getRecommendations(percentage),
            style: TextStyle(
              fontSize: textSize,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 14),
          
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: AppColors.primaryGreen,
                  size: isDesktop ? 24 : isTablet ? 20 : 18,
                ),
                SizedBox(width: isDesktop ? 12 : isTablet ? 10 : 8),
                Expanded(
                  child: Text(
                    _getIslamicQuote(),
                    style: TextStyle(
                      fontSize: textSize,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primaryGreen,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  
  // Helper methods
  Widget _buildStatCard(String label, String value, Color color, bool isTablet, bool isDesktop, bool isSmallMobile) {
    final valueSize = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallMobile ? 18.0 : 20.0;
    final labelSize = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallMobile ? 10.0 : 11.0;
    final padding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallMobile ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isDesktop ? 4 : 2),
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionItem(String question, IconData icon, bool answered, bool isTablet, bool isDesktop, bool isSmallMobile) {
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallMobile ? 18.0 : 20.0;
    final textSize = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallMobile ? 12.0 : 13.0;
    final padding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallMobile ? 10.0 : 12.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : isTablet ? 10 : 8),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: answered ? AppColors.primaryGreen.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: answered ? AppColors.primaryGreen.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 8 : isTablet ? 7 : 6),
            decoration: BoxDecoration(
              color: answered ? AppColors.primaryGreen : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : isTablet ? 14 : 12),
          Expanded(
            child: Text(
              question,
              style: TextStyle(
                fontSize: textSize,
                color: answered ? AppColors.primaryGreen : AppColors.textSecondary,
                fontWeight: answered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Icon(
            answered ? Icons.check_circle : Icons.cancel,
            color: answered ? AppColors.primaryGreen : Colors.grey[400],
            size: iconSize,
          ),
        ],
      ),
    );
  }
  
  Color _getProgressColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.primaryGreen;
    } else if (percentage >= 60) {
      return const Color(0xFF38A169); // AppColors.accentTeal alternative
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return const Color(0xFFE53E3E); // AppColors.accentRed alternative
    }
  }

  IconData _getProgressIcon(double percentage) {
    if (percentage >= 80) {
      return Icons.sentiment_very_satisfied;
    } else if (percentage >= 60) {
      return Icons.sentiment_satisfied;
    } else if (percentage >= 40) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage >= 90) {
      return 'Excellent! Keep up the great spiritual journey!';
    } else if (percentage >= 70) {
      return 'Well done! You\'re making wonderful progress.';
    } else if (percentage >= 50) {
      return 'Good effort! Tomorrow is another opportunity to grow.';
    } else {
      return 'Every step counts. May Allah guide your journey.';
    }
  }

  String _getRecommendations(double percentage) {
    if (percentage >= 80) {
      return 'Maintain your excellent spiritual practices. Consider teaching others and being a role model in your community.';
    } else if (percentage >= 60) {
      return 'You\'re on a good path. Focus on consistency in your daily acts of worship and increase your voluntary prayers.';
    } else if (percentage >= 40) {
      return 'Work on establishing regular prayer times and increase your Quran reading. Small, consistent steps lead to big changes.';
    } else {
      return 'Start with the basics: establish your five daily prayers and begin reading the Quran regularly. Remember, Allah loves consistent good deeds.';
    }
  }
}
